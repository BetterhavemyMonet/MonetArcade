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
