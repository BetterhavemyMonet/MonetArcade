import { useLiveLobby } from "@/hooks/useLiveLobby";
import { useNavigate } from "react-router-dom";

const GAMES = [
  { id: "mario", name: "Monet Mario" },
  { id: "shooter", name: "Arena Shooter" },
  { id: "drift", name: "Drift Royale" },
  { id: "toads", name: "Toad Runner" },
];

export default function Lobby() {
  const { connectedPlayers, queue, status } = useLiveLobby();
  const nav = useNavigate();

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-xl font-bold">🎮 Live Arcade Lobby</h1>

      <div className="text-sm opacity-70">
        Status: {status}
      </div>

      {/* GLOBAL STATS */}
      <div className="border rounded p-4">
        <div>👥 Online Players: {connectedPlayers}</div>
      </div>

      {/* GAME QUEUES */}
      <div className="grid gap-3">
        {GAMES.map((g) => (
          <div
            key={g.id}
            className="border p-3 rounded flex justify-between items-center"
          >
            <div>
              <div className="font-semibold">{g.name}</div>
              <div className="text-xs opacity-60">
                Queue: {queue[g.id] || 0}
              </div>
            </div>

            <button
              onClick={() => nav(`/games?join=${g.id}`)}
              className="bg-blue-600 text-white px-3 py-1 rounded"
            >
              Join
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}
