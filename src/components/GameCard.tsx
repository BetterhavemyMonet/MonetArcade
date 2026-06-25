import { useState } from "react";
import { Play, Lock, Loader2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";
import { toast } from "sonner";
import { useWallet } from "@/context/WalletContext";
import {
  getMonetPrice,
  payEntryFee,
  verifyTransaction,
  startGameSession,
} from "@/services/monetArcade";

export type GameStatus = "live" | "beta" | "soon";

export interface Game {
  id: string;
  title: string;
  description: string;
  image: string;
  status: GameStatus;
  players?: string;
  category?: string;
}

const statusStyles: Record<GameStatus, string> = {
  live: "bg-neon-green/15 text-neon-green border-neon-green/40",
  beta: "bg-neon-blue/15 text-neon-blue border-neon-blue/40",
  soon: "bg-muted text-muted-foreground border-border",
};

type Stage = "idle" | "wallet" | "price" | "pay" | "verify" | "session";

const stageLabel: Record<Stage, string> = {
  idle: "Play Now",
  wallet: "Connecting wallet…",
  price: "Fetching $MONET price…",
  pay: "Paying entry fee…",
  verify: "Verifying transaction…",
  session: "Starting session…",
};

const GameCard = ({ game }: { game: Game }) => {
  const locked = game.status === "soon";
  const { wallet, connect } = useWallet();
  const [stage, setStage] = useState<Stage>("idle");
  const busy = stage !== "idle";

  const handlePlay = async () => {
    if (locked) {
      toast("Coming soon", { description: "This title will be live shortly." });
      return;
    }
    try {
      let addr = wallet;
      if (!addr) {
        setStage("wallet");
        addr = await connect();
      }
      setStage("price");
      const price = await getMonetPrice();
      setStage("pay");
      const tx = await payEntryFee({ wallet: addr, entryFeeMonet: price.entryFeeMonet });
      setStage("verify");
      const v = await verifyTransaction(tx);
      if (!v.verified) throw new Error("Entry not verified on-chain");
      setStage("session");
      const session = await startGameSession({ wallet: addr, gameId: game.id });
      toast.success(`Launching ${game.title}`, {
        description: `Session ${String(session.sessionId).slice(0, 8)}… ready.`,
      });
      // INTEGRATION POINT: hand `session` to the game runner (iframe / WebGL bundle).
    } catch (e) {
      toast.error("Couldn't start game", {
        description: e instanceof Error ? e.message : "Unknown error",
      });
    } finally {
      setStage("idle");
    }
  };

  return (
    <article className="glass-panel rounded-xl overflow-hidden hover-glow group animate-fade-in">
      <div className="relative aspect-square overflow-hidden">
        <img
          src={game.image}
          alt={`${game.title} arcade game cover`}
          loading="lazy"
          className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-background via-background/40 to-transparent" />
        <Badge className={cn("absolute top-3 right-3 uppercase tracking-wider text-xs border", statusStyles[game.status])}>
          {game.status}
        </Badge>
        {game.category && (
          <Badge variant="outline" className="absolute top-3 left-3 bg-background/70 backdrop-blur text-xs">
            {game.category}
          </Badge>
        )}
      </div>
      <div className="p-5 space-y-3">
        <div className="flex items-start justify-between gap-2">
          <h3 className="font-display text-xl text-foreground">{game.title}</h3>
          {game.players && (
            <span className="text-xs text-neon-teal font-semibold whitespace-nowrap">
              {game.players} online
            </span>
          )}
        </div>
        <p className="text-sm text-muted-foreground line-clamp-2">{game.description}</p>
        <Button
          onClick={handlePlay}
          disabled={locked || busy}
          className="w-full bg-gradient-primary text-primary-foreground font-semibold hover:shadow-glow-teal transition-all disabled:opacity-50"
        >
          {locked ? (
            <Lock className="h-4 w-4 mr-2" />
          ) : busy ? (
            <Loader2 className="h-4 w-4 mr-2 animate-spin" />
          ) : (
            <Play className="h-4 w-4 mr-2" />
          )}
          {locked ? "Coming Soon" : busy ? stageLabel[stage] : "Play Now"}
        </Button>
      </div>
    </article>
  );
};

export default GameCard;
