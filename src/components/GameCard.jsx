import { useWallet, useConnection } from "@solana/wallet-adapter-react";
import { playGame } from "../pay/playGame";

export default function GameCard({ game }) {
  const wallet = useWallet();
  const { connection } = useConnection();

  return (
    <div className="bg-black/40 border border-white/10 rounded-xl p-4 text-white">
      
      <h2 className="text-xl font-bold">{game.title}</h2>

      <p className="text-green-400 mt-1">
        {game.price} MONET
      </p>

      <p className="text-gray-400 text-sm mt-1">
        {game.type}
      </p>

      <button
        className="mt-4 w-full bg-purple-600 hover:bg-purple-700 p-2 rounded-lg"
        onClick={() => playGame(game.id, wallet, connection)}
      >
        Pay 100 MONET & Play
      </button>
    </div>
  );
}
