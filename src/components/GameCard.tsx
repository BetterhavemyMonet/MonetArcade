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
