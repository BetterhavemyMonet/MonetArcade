#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "🎮 Installing ROOM GAME ENGINE LAYER..."

cd ~/MonetArcade || exit 1

mkdir -p src/hooks src/pages

# -----------------------------
# SOCKET ROOM ENGINE HOOK
# -----------------------------
cat > src/hooks/useRoom.ts << 'EOT'
import { useEffect, useRef, useState } from "react";
import { io } from "socket.io-client";

const API = import.meta.env.VITE_ARCADE_API_URL;

export function useRoom(roomId?: string) {
  const socketRef = useRef<any>(null);

  const [players, setPlayers] = useState<string[]>([]);
  const [scores, setScores] = useState<Record<string, number>>({});
  const [status, setStatus] = useState("connecting");

  useEffect(() => {
    if (!roomId) return;

    const socket = io(API);
    socketRef.current = socket;

    socket.emit("room:join", { roomId });

    socket.on("room:state", (data) => {
      setPlayers(data.players || []);
      setScores(data.scores || {});
    });

    socket.on("room:player_joined", (data) => {
      setPlayers((p) => [...new Set([...p, data.wallet])]);
    });

    socket.on("room:score_update", (data) => {
      setScores((s) => ({
        ...s,
        [data.wallet]: data.score,
      }));
    });

    socket.on("room:status", (data) => {
      setStatus(data.status);
    });

    return () => socket.disconnect();
  }, [roomId]);

  const submitScore = (wallet: string, score: number) => {
    socketRef.current?.emit("room:score", {
      roomId,
      wallet,
      score,
    });
  };

  const finishMatch = (wallet: string, score: number) => {
    socketRef.current?.emit("room:finish", {
      roomId,
      wallet,
      score,
    });
  };

  return {
    players,
    scores,
    status,
    submitScore,
    finishMatch,
  };
}
EOT

# -----------------------------
# UPGRADED ROOM PAGE
# -----------------------------
cat > src/pages/Room.tsx << 'EOT'
import { useParams } from "react-router-dom";
import { useRoom } from "@/hooks/useRoom";
import { useWallet } from "@/context/WalletContext";

export default function Room() {
  const { id } = useParams();
  const { wallet } = useWallet();

  const {
    players,
    scores,
    status,
    submitScore,
    finishMatch,
  } = useRoom(id);

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-xl font-bold">🎮 Room: {id}</h1>

      <div className="text-sm opacity-70">
        Status: {status}
      </div>

      {/* PLAYERS */}
      <div className="border rounded p-3">
        <h2 className="font-semibold mb-2">👥 Players</h2>
        {players.map((p) => (
          <div key={p} className="text-sm">
            👤 {p}
          </div>
        ))}
      </div>

      {/* SCORES */}
      <div className="border rounded p-3">
        <h2 className="font-semibold mb-2">🏁 Live Scores</h2>

        {Object.entries(scores).length === 0 ? (
          <div className="text-sm opacity-60">No scores yet</div>
        ) : (
          Object.entries(scores).map(([wallet, score]) => (
            <div key={wallet} className="text-sm">
              {wallet}: {score}
            </div>
          ))
        )}
      </div>

      {/* DEV CONTROLS (replace with real game engine later) */}
      <div className="space-x-2">
        <button
          onClick={() => submitScore(wallet!, Math.floor(Math.random() * 100))}
          className="bg-blue-600 text-white px-3 py-1 rounded"
        >
          🎯 Submit Score
        </button>

        <button
          onClick={() => finishMatch(wallet!, 999)}
          className="bg-green-600 text-white px-3 py-1 rounded"
        >
          🏁 Finish Match
        </button>
      </div>
    </div>
  );
}
EOT

echo "✅ Room engine installed"
echo "👉 Backend socket handlers required next"
