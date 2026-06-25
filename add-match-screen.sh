#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "🎮 Installing FULL MATCH SCREEN SYSTEM..."

cd ~/MonetArcade || exit 1

mkdir -p src/pages src/hooks

# -----------------------------
# SOCKET LOBBY HOOK (UPGRADED)
# -----------------------------
cat > src/hooks/useLobby.ts << 'EOT'
import { useEffect, useRef, useState } from "react";
import { io } from "socket.io-client";

const API = import.meta.env.VITE_ARCADE_API_URL;

export function useLobby(wallet?: string | null) {
  const socketRef = useRef<any>(null);

  const [status, setStatus] = useState<
    "idle" | "queue" | "matched" | "joining"
  >("idle");

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
      setStatus("matched");
    });

    return () => socket.disconnect();
  }, []);

  const joinQueue = (gameId: string) => {
    if (!wallet) return;

    setStatus("queue");

    socketRef.current.emit("queue:join", {
      wallet,
      gameId,
    });
  };

  const leaveQueue = (gameId: string) => {
    if (!wallet) return;

    setStatus("idle");

    socketRef.current.emit("queue:leave", {
      wallet,
      gameId,
    });
  };

  return {
    status,
    queueSize,
    match,
    joinQueue,
    leaveQueue,
  };
}
EOT

# -----------------------------
# MATCH SCREEN PAGE
# -----------------------------
cat > src/pages/Match.tsx << 'EOT'
import { useEffect } from "react";
import { useNavigate } from "react-router-dom";

export default function Match({ match }: any) {
  const nav = useNavigate();

  useEffect(() => {
    if (!match?.roomId) return;

    const t = setTimeout(() => {
      nav(`/room/${match.roomId}`);
    }, 1500);

    return () => clearTimeout(t);
  }, [match]);

  if (!match) {
    return (
      <div className="p-10 text-center">
        🔍 Searching for players...
      </div>
    );
  }

  return (
    <div className="p-10 text-center space-y-4">
      <h1 className="text-2xl font-bold">🎯 Match Found!</h1>

      <div className="text-sm opacity-70">
        Game: {match.gameId}
      </div>

      <div className="text-sm">
        Players:
        <div className="mt-2">
          {match.players?.map((p: string, i: number) => (
            <div key={i}>👤 {p}</div>
          ))}
        </div>
      </div>

      <div className="animate-pulse mt-4">
        🚀 Joining room...
      </div>
    </div>
  );
}
EOT

# -----------------------------
# ROOM PAGE (LIVE GAME SHELL)
# -----------------------------
cat > src/pages/Room.tsx << 'EOT'
import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";

export default function Room() {
  const { id } = useParams();
  const [players, setPlayers] = useState<string[]>([]);

  useEffect(() => {
    // placeholder for future socket room sync
    console.log("Entered room:", id);
  }, [id]);

  return (
    <div className="p-10 space-y-4">
      <h1 className="text-xl font-bold">🎮 Room: {id}</h1>

      <div className="opacity-70">Waiting for game engine integration...</div>

      <div className="border p-4 rounded">
        <h2 className="font-semibold">Players</h2>
        {players.length === 0 ? (
          <div className="text-sm opacity-60">Syncing...</div>
        ) : (
          players.map((p, i) => <div key={i}>👤 {p}</div>)
        )}
      </div>
    </div>
  );
}
EOT

echo "✅ Match screen system installed"
echo "👉 Next: wire routes (Games → Match → Room)"
