#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "🎮 Installing GAME REGISTRY + LOBBY FIX..."

cd ~/MonetArcade || exit 1

mkdir -p src/data

cat > src/data/games.ts << 'EOT'
export interface Game {
  id: string;
  title: string;
  image: string;
  entryFee: number;
  players: number;
  mode: string;
}

export const games: Game[] = [
  {
    id: "mario",
    title: "Monet Mario",
    image: "/src/assets/game-mario.jpg",
    entryFee: 1,
    players: 2,
    mode: "Platform",
  },
  {
    id: "drift",
    title: "Monet Drift",
    image: "/src/assets/game-drift.jpg",
    entryFee: 1,
    players: 2,
    mode: "Racing",
  },
  {
    id: "shooter",
    title: "Monet Shooter",
    image: "/src/assets/game-shooter.jpg",
    entryFee: 1,
    players: 4,
    mode: "FPS",
  },
  {
    id: "toads",
    title: "Token Toads",
    image: "/src/assets/game-toads.jpg",
    entryFee: 1,
    players: 3,
    mode: "Arcade",
  },
  {
    id: "blocks",
    title: "Monet Blocks",
    image: "/src/assets/game-blocks.jpg",
    entryFee: 1,
    players: 1,
    mode: "Puzzle",
  },
];
EOT

echo "🧩 Updating Games page..."

cat > src/pages/Games.tsx << 'EOT'
import { games } from "@/data/games";
import GameCard from "@/components/GameCard";

export default function Games() {
  return (
    <div className="p-6 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      {games.map((game) => (
        <GameCard key={game.id} game={game} />
      ))}
    </div>
  );
}
EOT

echo "🧠 Updating GameCard to be generic..."

cat > src/components/GameCard.tsx << 'EOT'
import { useState } from "react";
import { payEntryFee, getMonetPrice, startGameSession } from "@/services/monetArcade";
import { useWallet } from "@/context/WalletContext";

export default function GameCard({ game }: any) {
  const { wallet, connect } = useWallet();
  const [loading, setLoading] = useState(false);

  const play = async () => {
    setLoading(true);

    try {
      const addr = wallet || await connect();
      const price = await getMonetPrice();

      const tx = await payEntryFee({
        wallet: addr,
        entryFeeMonet: price.entryFeeMonet,
      });

      await startGameSession({
        wallet: addr,
        gameId: game.id,
      });

      console.log("START GAME:", game.id, tx);
    } catch (e) {
      console.error(e);
    }

    setLoading(false);
  };

  return (
    <div className="rounded-xl overflow-hidden border bg-black text-white">
      <img src={game.image} className="h-40 w-full object-cover" />

      <div className="p-4 space-y-2">
        <h2 className="text-lg font-bold">{game.title}</h2>

        <p className="text-sm opacity-70">
          {game.mode} • {game.players} Players
        </p>

        <button
          onClick={play}
          disabled={loading}
          className="w-full bg-green-500 hover:bg-green-600 p-2 rounded"
        >
          {loading ? "Starting..." : `Play (${game.entryFee} MONET)`}
        </button>
      </div>
    </div>
  );
}
EOT

echo "🔌 Hooking lobby into same registry..."

cat > src/hooks/useLobby.ts << 'EOT'
import { useEffect, useState } from "react";
import { io } from "socket.io-client";

const socket = io(import.meta.env.VITE_ARCADE_API_URL);

export function useLobby() {
  const [lobby, setLobby] = useState<any>({});

  useEffect(() => {
    socket.on("lobby:update", setLobby);
    return () => {
      socket.off("lobby:update");
    };
  }, []);

  return lobby;
}
EOT

echo "✅ Game registry + lobby wired"
echo "👉 restart frontend: npm run dev"
