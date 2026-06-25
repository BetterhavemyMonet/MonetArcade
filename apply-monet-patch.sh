#!/data/data/com.termux/files/usr/bin/bash

echo "⚡ MonetArcade Patch Starting..."

# -------------------------
# FRONTEND: SAFE CONFIG FIXES
# -------------------------

cat > src/services/monetArcade.ts << 'EOF'
import { Connection } from "@solana/web3.js";

const API = import.meta.env.VITE_ARCADE_API_URL;

export async function connectWallet() {
  if (!window.solana) throw new Error("Wallet not found");
  const res = await window.solana.connect();
  return res.publicKey.toString();
}

async function sendMonetTransaction({ wallet, amount }) {
  if (!window.solana) throw new Error("Wallet missing");

  // placeholder signature (stable mode)
  const sig = await window.solana.signMessage({
    message: `MONET:${amount}:${wallet}`
  });

  return sig;
}

export async function payEntryFee(data) {
  return sendMonetTransaction(data);
}

export async function getMonetPrice() {
  const res = await fetch(`${API}/api/monet-price`);
  return res.json();
}

export async function startGameSession(data) {
  const res = await fetch(`${API}/api/start-game`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data)
  });
  return res.json();
}

export async function submitScore(data) {
  const res = await fetch(`${API}/api/submit-score`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data)
  });
  return res.json();
}
EOF

# -------------------------
# FRONTEND: WALLET CONTEXT FIX
# -------------------------

cat > src/context/WalletContext.tsx << 'EOF'
import { createContext, useCallback, useContext, useState } from "react";
import { connectWallet as svcConnect } from "@/services/monetArcade";

const Ctx = createContext(null);

export const WalletProvider = ({ children }) => {
  const [wallet, setWallet] = useState(null);
  const [connecting, setConnecting] = useState(false);

  const connect = useCallback(async () => {
    setConnecting(true);
    try {
      const addr = await svcConnect();
      setWallet(addr);
      return addr;
    } finally {
      setConnecting(false);
    }
  }, []);

  const disconnect = useCallback(() => {
    window.solana?.disconnect?.();
    setWallet(null);
  }, []);

  return (
    <Ctx.Provider value={{ wallet, connecting, connect, disconnect }}>
      {children}
    </Ctx.Provider>
  );
};

export const useWallet = () => {
  const ctx = useContext(Ctx);
  if (!ctx) throw new Error("Wallet missing provider");
  return ctx;
};
EOF

# -------------------------
# BACKEND PATCH (SAFE MODE)
# -------------------------

cat > ~/monet-backend/server.js << 'EOF'
const express = require("express");
const cors = require("cors");

const app = express();
app.use(express.json());
app.use(cors());

let sessions = {};
let pot = 0;

// PRICE
app.get("/api/monet-price", (req, res) => {
  res.json({ priceUsd: 0.99, entryFeeMonet: 1, entryFeeUsd: 0.99 });
});

// START GAME
app.post("/api/start-game", (req, res) => {
  const { wallet } = req.body;

  const sessionId = Math.random().toString(36).slice(2);

  sessions[sessionId] = { wallet, valid: true, claimed: false };

  pot += 1;

  res.json({ sessionId, pot });
});

// VERIFY ENTRY
app.post("/api/verify-entry", (req, res) => {
  const { sessionId } = req.body;

  if (!sessions[sessionId]) {
    return res.status(403).json({ verified: false });
  }

  res.json({ verified: true });
});

// WIN
app.post("/api/submit-score", (req, res) => {
  const { sessionId } = req.body;

  const session = sessions[sessionId];
  if (!session || session.claimed) {
    return res.status(403).json({ error: "Invalid" });
  }

  session.claimed = true;

  const payout = Math.floor(pot * 0.8);
  const treasury = Math.floor(pot * 0.2);

  pot = 0;

  res.json({ success: true, payout, treasury });
});

app.listen(3001, () => {
  console.log("🚀 Monet backend running on 3001");
});
EOF

echo "✅ Patch applied"
