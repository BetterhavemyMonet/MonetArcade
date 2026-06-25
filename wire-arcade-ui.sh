#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "🎮 Wiring MonetArcade UI + Live Lobby..."

cd ~/MonetArcade || exit 1

# -----------------------------
# ENSURE FOLDERS
# -----------------------------
mkdir -p src/hooks

# -----------------------------
# GAME HOOK (LIVE FROM BACKEND)
# -----------------------------
cat > src/hooks/useGames.ts << 'EOT'
import { useEffect, useState } from "react";

const API = import.meta.env.VITE_ARCADE_API_URL;

export function useGames() {
  const [games, setGames] = useState<any[]>([]);

  useEffect(() => {
    fetch(`${API}/api/games`)
      .then(r => r.json())
      .then(setGames)
      .catch(console.error);
  }, []);

  return games;
}
EOT

# -----------------------------
# LOBBY HOOK (REALTIME SOCKET)
# -----------------------------
cat > src/hooks/useLobby.ts << 'EOT'
import { useEffect, useRef, useState } from "react";
import { io } from "socket.io-client";

const API = import.meta.env.VITE_ARCADE_API_URL;

export function useLobby(wallet?: string | null) {
  const socketRef = useRef<any>(null);
  const [queueSize, setQueueSize] = useState(0);
  const [match, setMatch] = useState<any>(null);

  useEffect(() => {
    const socket = io(API);
    socketRef.current = socket;

    socket.on("queue:update", (data) => {
      setQueueSize(data.queueSize);
    });

    socket.on("match:found", (data) => {
      setMatch(data);
    });

    return () => socket.disconnect();
  }, []);

  const joinQueue = (gameId: string) => {
    if (!wallet) return;
    socketRef.current.emit("queue:join", { wallet, gameId });
  };

  const leaveQueue = (gameId: string) => {
    if (!wallet) return;
    socketRef.current.emit("queue:leave", { wallet, gameId });
  };

  return { queueSize, match, joinQueue, leaveQueue };
}
EOT

# -----------------------------
# GAMES PAGE WIRED
# -----------------------------
cat > src/pages/Games.tsx << 'EOT'
import { useGames } from "@/hooks/useGames";
import GameCard from "@/components/GameCard";

export default function Games() {
  const games = useGames();

  return (
    <div className="grid gap-4 grid-cols-1 md:grid-cols-2 lg:grid-cols-3 p-6">
      {games.map((game) => (
        <GameCard key={game.id} game={game} />
      ))}
    </div>
  );
}
EOT

# -----------------------------
# GAMECARD UPDATED FLOW
# -----------------------------
cat > src/components/GameCard.tsx << 'EOT'
import { useState } from "react";
import { useWallet } from "@/context/WalletContext";
import {
  payEntryFee,
  startGameSession,
  getMonetPrice,
} from "@/services/monetArcade";

export default function GameCard({ game }: any) {
  const { wallet, connect } = useWallet();
  const [loading, setLoading] = useState(false);

  const play = async () => {
    try {
      setLoading(true);

      const addr = wallet || (await connect());
      const price = await getMonetPrice();

      await payEntryFee({
        wallet: addr,
        entryFeeMonet: price.entryFeeMonet,
      });

      const session = await startGameSession({
        wallet: addr,
        gameId: game.id,
      });

      console.log("🎮 SESSION:", session);
    } catch (e) {
      console.error(e);
      alert("Failed to start game");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="border rounded-xl p-4 flex flex-col gap-3">
      <h2 className="text-xl font-bold">{game.title}</h2>

      <div className="text-sm opacity-70">
        Entry Fee: {game.entryFee}
      </div>

      <button
        onClick={play}
        disabled={loading}
        className="bg-purple-600 text-white p-2 rounded"
      >
        {loading ? "Entering..." : "Play"}
      </button>
    </div>
  );
}
EOT

echo "✅ UI + Lobby wired successfully"
echo "👉 Next: run npm run dev"
