import { useEffect, useState } from "react";
import { Trophy } from "lucide-react";

/**
 * Live prize pool placeholder. INTEGRATION POINT: replace with on-chain
 * or backend feed once payments are wired up.
 */
const PrizePool = () => {
  const [amount, setAmount] = useState(124_580);

  useEffect(() => {
    const t = setInterval(() => setAmount((a) => a + Math.floor(Math.random() * 20)), 1500);
    return () => clearInterval(t);
  }, []);

  return (
    <div className="glass-panel rounded-2xl p-6 md:p-8 relative overflow-hidden animate-pulse-glow">
      <div className="absolute inset-0 grid-bg opacity-30" />
      <div className="relative flex items-center gap-5">
        <div className="p-4 rounded-xl bg-gradient-accent shadow-glow-green">
          <Trophy className="h-8 w-8 text-background" />
        </div>
        <div className="flex-1">
          <p className="text-xs uppercase tracking-widest text-muted-foreground">Live Prize Pool</p>
          <p className="font-display text-3xl md:text-5xl font-black text-gradient-accent tabular-nums">
            ${amount.toLocaleString()}
          </p>
          <p className="text-sm text-muted-foreground mt-1">
            <span className="inline-block w-2 h-2 rounded-full bg-neon-green mr-2 animate-pulse" />
            Updated in real-time
          </p>
        </div>
      </div>
    </div>
  );
};

export default PrizePool;
