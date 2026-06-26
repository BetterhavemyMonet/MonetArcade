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
