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
