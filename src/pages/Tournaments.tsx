import { Calendar, Trophy, Users, Clock } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { toast } from "sonner";

const tournaments = [
  {
    id: "t1",
    title: "Neon Grand Prix",
    game: "Monet Drift",
    date: "Jun 28, 2026",
    prize: "$25,000",
    entry: "Free",
    players: "1,240 / 2,000",
    status: "open",
  },
  {
    id: "t2",
    title: "Block Master Cup",
    game: "Neon Blocks",
    date: "Jul 02, 2026",
    prize: "$10,000",
    entry: "100 TOKENS",
    players: "412 / 1,000",
    status: "open",
  },
  {
    id: "t3",
    title: "Toad Token Hunt",
    game: "Token Toads",
    date: "Jul 10, 2026",
    prize: "$5,000",
    entry: "50 TOKENS",
    players: "Coming soon",
    status: "soon",
  },
];

const rankings = [
  { rank: 1, name: "VoltStrike", winnings: "$84,200" },
  { rank: 2, name: "NeonSamurai", winnings: "$62,400" },
  { rank: 3, name: "GlitchQueen", winnings: "$51,180" },
  { rank: 4, name: "CipherX", winnings: "$42,910" },
  { rank: 5, name: "PulseWave", winnings: "$38,720" },
];

const Tournaments = () => {
  const handleRegister = (title: string) => {
    // INTEGRATION POINT: payment + auth gating before tournament registration.
    toast(`Registration pending`, { description: `Sign-up for ${title} will open once accounts are enabled.` });
  };

  return (
    <div className="container py-12 animate-fade-in space-y-10">
      <header>
        <h1 className="font-display text-4xl md:text-6xl font-black">
          <span className="text-gradient-accent">Tournaments</span>
        </h1>
        <p className="text-muted-foreground mt-2">Compete for real prize pools. Earn your spot on the global ladder.</p>
      </header>

      <section className="grid lg:grid-cols-3 gap-6">
        {tournaments.map((t) => (
          <article key={t.id} className="glass-panel rounded-2xl p-6 hover-glow relative overflow-hidden">
            <div className="absolute inset-0 grid-bg opacity-20" />
            <div className="relative space-y-4">
              <div className="flex items-start justify-between">
                <div>
                  <Badge variant="outline" className="text-neon-teal border-neon-teal/40 mb-2">{t.game}</Badge>
                  <h3 className="font-display text-2xl font-bold">{t.title}</h3>
                </div>
                <Badge className={t.status === "open" ? "bg-neon-green/15 text-neon-green border-neon-green/40" : "bg-muted text-muted-foreground"}>
                  {t.status === "open" ? "Open" : "Soon"}
                </Badge>
              </div>

              <div className="grid grid-cols-2 gap-3 text-sm">
                <div className="flex items-center gap-2 text-muted-foreground"><Calendar className="h-4 w-4 text-neon-teal" /> {t.date}</div>
                <div className="flex items-center gap-2 text-muted-foreground"><Users className="h-4 w-4 text-neon-blue" /> {t.players}</div>
                <div className="flex items-center gap-2 text-muted-foreground"><Trophy className="h-4 w-4 text-neon-green" /> {t.prize}</div>
                <div className="flex items-center gap-2 text-muted-foreground"><Clock className="h-4 w-4 text-neon-magenta" /> {t.entry}</div>
              </div>

              <div className="pt-2 border-t border-border">
                <p className="text-xs uppercase tracking-widest text-muted-foreground mb-1">Prize Pool</p>
                <p className="font-display text-3xl font-black text-gradient-accent">{t.prize}</p>
              </div>

              <Button
                onClick={() => handleRegister(t.title)}
                disabled={t.status !== "open"}
                className="w-full bg-gradient-primary text-primary-foreground font-bold uppercase tracking-wider hover:shadow-glow-teal"
              >
                {t.status === "open" ? "Register" : "Coming Soon"}
              </Button>
            </div>
          </article>
        ))}
      </section>

      <section>
        <h2 className="font-display text-2xl md:text-3xl mb-4 flex items-center gap-2">
          <Trophy className="text-neon-green" /> Global Rankings
        </h2>
        <div className="glass-panel rounded-xl divide-y divide-border overflow-hidden">
          {rankings.map((r) => (
            <div key={r.rank} className="flex items-center justify-between px-6 py-4">
              <div className="flex items-center gap-4">
                <span className={`font-display text-2xl font-black w-10 ${r.rank === 1 ? "text-neon-green" : r.rank === 2 ? "text-neon-teal" : r.rank === 3 ? "text-neon-blue" : "text-muted-foreground"}`}>
                  #{r.rank}
                </span>
                <span className="font-semibold">{r.name}</span>
              </div>
              <span className="font-display text-lg text-gradient-accent tabular-nums">{r.winnings}</span>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
};

export default Tournaments;
