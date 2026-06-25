import drift from "@/assets/game-drift.jpg";
import mario from "@/assets/game-mario.jpg";
import toads from "@/assets/game-toads.jpg";
import blocks from "@/assets/game-blocks.jpg";
import shooter from "@/assets/game-shooter.jpg";
import type { Game } from "@/components/GameCard";

export const games: Game[] = [
  {
    id: "monet-drift",
    title: "Monet Drift",
    description: "High-octane neon street racing. Drift, boost, and outrun the grid.",
    image: drift,
    status: "live",
    players: "2.4k",
    category: "Racing",
  },
  {
    id: "monet-mario",
    title: "Monet Mario",
    description: "Pixel-perfect platforming through neon worlds. Stomp, jump, glow.",
    image: mario,
    status: "live",
    players: "1.8k",
    category: "Platformer",
  },
  {
    id: "token-toads",
    title: "Token Toads",
    description: "Collect glowing tokens with the cutest amphibians in the metaverse.",
    image: toads,
    status: "beta",
    players: "920",
    category: "Casual",
  },
  {
    id: "neon-blocks",
    title: "Neon Blocks",
    description: "A Tetris-style descent into pure geometric flow state.",
    image: blocks,
    status: "live",
    players: "3.1k",
    category: "Puzzle",
  },
  {
    id: "void-runner",
    title: "Void Runner",
    description: "Blast through neon nebulas in this retro arcade shooter.",
    image: shooter,
    status: "soon",
    category: "Shooter",
  },
  {
    id: "grid-clash",
    title: "Grid Clash",
    description: "Real-time PvP duels on a luminous 8-bit battle grid.",
    image: drift,
    status: "soon",
    category: "PvP",
  },
];
