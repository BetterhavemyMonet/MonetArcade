import { useEffect, useState } from "react";
import GameCard from "../components/GameCard";

export default function Arcade() {
  const [games, setGames] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch("http://localhost:5000/api/games")
      .then(res => res.json())
      .then(data => {
        setGames(data);
        setLoading(false);
      })
      .catch(() => setLoading(false));
  }, []);

  if (loading) {
    return (
      <div className="text-white p-6">
        Loading Arcade...
      </div>
    );
  }

  return (
    <div className="p-6 grid grid-cols-1 md:grid-cols-3 gap-4">
      {games.map(game => (
        <GameCard key={game.id} game={game} />
      ))}
    </div>
  );
}
