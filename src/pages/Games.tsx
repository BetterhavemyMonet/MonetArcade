import { useState } from "react";
import { Search } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import GameCard from "@/components/GameCard";
import { games } from "@/data/games";
import { cn } from "@/lib/utils";

const categories = ["All", "Racing", "Platformer", "Puzzle", "Shooter", "Casual", "PvP"];

const Games = () => {
  const [q, setQ] = useState("");
  const [cat, setCat] = useState("All");

  const filtered = games.filter(
    (g) =>
      (cat === "All" || g.category === cat) &&
      g.title.toLowerCase().includes(q.toLowerCase())
  );

  return (
    <div className="container py-12 animate-fade-in">
      <header className="mb-10">
        <h1 className="font-display text-4xl md:text-6xl font-black">
          Game <span className="text-gradient-primary">Lobby</span>
        </h1>
        <p className="text-muted-foreground mt-2">Pick your title. Stake your skill.</p>
      </header>

      <div className="flex flex-col md:flex-row gap-4 mb-8">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
          <Input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Search games…"
            className="pl-10 bg-card border-border h-12"
          />
        </div>
        <div className="flex gap-2 overflow-x-auto pb-1">
          {categories.map((c) => (
            <Button
              key={c}
              onClick={() => setCat(c)}
              variant="outline"
              className={cn(
                "border-border whitespace-nowrap uppercase tracking-wide text-xs",
                cat === c && "border-neon-teal text-neon-teal shadow-glow-teal bg-neon-teal/5"
              )}
            >
              {c}
            </Button>
          ))}
        </div>
      </div>

      {filtered.length === 0 ? (
        <p className="text-center text-muted-foreground py-20">No games match your search.</p>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
          {filtered.map((g) => <GameCard key={g.id} game={g} />)}
        </div>
      )}
    </div>
  );
};

export default Games;
