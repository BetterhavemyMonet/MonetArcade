#!/data/data/com.termux/files/usr/bin/bash
set -e

cd ~/MonetArcade || exit 1

echo "🎮 Restoring BLUE GAME MENU UI..."

mkdir -p src/data

cat > src/data/games.ts << 'EOT'
export const games = [
  {
    id: "mario",
    title: "Monet Mario",
    image: "/src/assets/game-mario.jpg",
    entryFee: 1,
  },
  {
    id: "drift",
    title: "Monet Drift",
    image: "/src/assets/game-drift.jpg",
    entryFee: 1,
  },
  {
    id: "shooter",
    title: "Monet Shooter",
    image: "/src/assets/game-shooter.jpg",
    entryFee: 1,
  },
  {
    id: "toads",
    title: "Token Toads",
    image: "/src/assets/game-toads.jpg",
    entryFee: 1,
  }
];
EOT

cat > src/pages/Games.tsx << 'EOT'
import { games } from "@/data/games";

export default function Games() {
  return (
    <div className="min-h-screen bg-blue-950 text-white p-6">
      <h1 className="text-3xl font-bold mb-6">Monet Arcade</h1>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {games.map((g) => (
          <div key={g.id} className="bg-blue-900 rounded-xl p-4 border border-blue-700">
            <img src={g.image} className="h-40 w-full object-cover rounded" />
            <h2 className="text-xl font-bold mt-2">{g.title}</h2>
            <p className="text-sm opacity-70">Entry: {g.entryFee} MONET</p>

            <button className="mt-3 w-full bg-blue-500 hover:bg-blue-600 p-2 rounded">
              Play
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}
EOT

echo "✅ Blue UI restored"
echo "👉 run: npm run dev"
