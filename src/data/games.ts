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
