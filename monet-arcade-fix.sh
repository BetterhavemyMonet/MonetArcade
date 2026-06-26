#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "🛠️ MonetArcade FULL FIX + REALTIME PATCH"

cd ~/MonetArcade || exit 1

# ----------------------------
# 1. CLEAN FRONTEND CACHE
# ----------------------------
echo "🧹 Cleaning Vite cache..."
rm -rf node_modules/.vite dist

# ----------------------------
# 2. ENSURE SOCKET CLIENT
# ----------------------------
echo "📦 Ensuring socket.io-client..."
npm install socket.io-client

# ----------------------------
# 3. FIX TS SERVICE LAYER (SAFE PATCH)
# ----------------------------
echo "🔧 Patching monetArcade service..."

cat > src/services/monetArcade.ts << 'EOT'
// Monet Arcade unified service layer (FIXED)

const API = import.meta.env.VITE_ARCADE_API_URL as string;

if (!API) {
  throw new Error("VITE_ARCADE_API_URL missing");
}

export async function connectWallet(): Promise<string> {
  if (!window.solana) throw new Error("No wallet found");
  const res = await window.solana.connect();
  return res.publicKey.toString();
}

export async function getMonetPrice() {
  const res = await fetch(`${API}/api/monet-price`);
  if (!res.ok) throw new Error("price fetch failed");
  return res.json();
}

export async function verifyTransaction(txSignature: string) {
  const res = await fetch(`${API}/api/verify-entry`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ txSignature }),
  });
  return res.json();
}

export async function startGameSession(data: {
  wallet: string;
  gameId: string;
}) {
  const res = await fetch(`${API}/api/start-game`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });
  return res.json();
}

export async function submitScore(data: {
  wallet: string;
  gameId: string;
  sessionId: string;
  score: number;
}) {
  const res = await fetch(`${API}/api/submit-score`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });
  return res.json();
}
EOT

# ----------------------------
# 4. ADD REALTIME HOOK
# ----------------------------
echo "⚡ Adding realtime lobby hook..."

mkdir -p src/hooks

cat > src/hooks/useLobby.ts << 'EOT'
import { useEffect, useState } from "react";
import { io } from "socket.io-client";

const socket = io(import.meta.env.VITE_ARCADE_API_URL);

export function useLobby() {
  const [lobby, setLobby] = useState<any>(null);

  useEffect(() => {
    socket.on("lobby:update", setLobby);
    return () => {
      socket.disconnect();
    };
  }, []);

  return lobby;
}
EOT

# ----------------------------
# 5. ENSURE ENV EXISTS
# ----------------------------
if [ ! -f .env ]; then
  echo "VITE_ARCADE_API_URL=http://localhost:3001" > .env
  echo "🧾 Created .env"
fi

# ----------------------------
# DONE
# ----------------------------
echo "✅ FIX COMPLETE"
echo "👉 Now run:"
echo "   npm run dev"
