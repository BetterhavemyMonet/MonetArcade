import { Link } from "react-router-dom";
import { ArrowRight, Sparkles, Trophy, Zap } from "lucide-react";
import { Button } from "@/components/ui/button";
import GameCard from "@/components/GameCard";
import PrizePool from "@/components/PrizePool";
import { games } from "@/data/games";
import hero from "@/assets/hero.jpg";

const Home = () => {
  const featured = games.slice(0, 4);
  return (
    <div className="animate-fade-in">
      {/* Hero */}
      <section className="relative overflow-hidden">
        <div className="absolute inset-0">
          <img src={hero} alt="" width={1920} height={1024} className="w-full h-full object-cover opacity-40" />
          <div className="absolute inset-0 bg-gradient-to-b from-background/40 via-background/70 to-background" />
        </div>
        <div className="container relative py-20 md:py-32 grid lg:grid-cols-2 gap-10 items-center">
          <div className="space-y-6 animate-fade-in">
            <span className="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs uppercase tracking-widest border border-neon-teal/40 text-neon-teal bg-neon-teal/5">
              <Sparkles className="h-3 w-3" /> Web3 Powered Arcade
            </span>
            <h1 className="font-display text-5xl md:text-7xl font-black leading-[0.95]">
              Play. <span className="text-gradient-primary">Compete.</span><br />
              <span className="text-gradient-accent">Win it all.</span>
            </h1>
            <p className="text-lg text-muted-foreground max-w-xl">
              Step into Monet Arcade — a neon-soaked gaming universe where every
              high score is rewarded and every tournament has real stakes.
            </p>
            <div className="flex flex-wrap gap-4">
              <Button asChild size="lg" className="bg-gradient-primary text-primary-foreground font-bold uppercase tracking-wider hover:shadow-glow-teal">
                <Link to="/games">Enter the Arcade <ArrowRight className="ml-2 h-4 w-4" /></Link>
              </Button>
              <Button asChild size="lg" variant="outline" className="border-neon-blue/50 text-neon-blue hover:bg-neon-blue/10 hover:text-neon-blue uppercase tracking-wider">
                <Link to="/tournaments">View Tournaments</Link>
              </Button>
            </div>
            <div className="grid grid-cols-3 gap-4 pt-6 max-w-md">
              {[
                { icon: Zap, label: "Active Players", value: "12.4k" },
                { icon: Trophy, label: "Tournaments", value: "48" },
                { icon: Sparkles, label: "Games", value: "20+" },
              ].map((s) => (
                <div key={s.label} className="glass-panel rounded-lg p-3 text-center">
                  <s.icon className="h-4 w-4 mx-auto text-neon-teal mb-1" />
                  <div className="font-display font-bold text-lg">{s.value}</div>
                  <div className="text-[10px] uppercase tracking-wider text-muted-foreground">{s.label}</div>
                </div>
              ))}
            </div>
          </div>

          <div className="animate-float">
            <PrizePool />
          </div>
        </div>
      </section>

      {/* Featured games */}
      <section className="container py-16 md:py-24">
        <div className="flex items-end justify-between mb-10">
          <div>
            <h2 className="font-display text-3xl md:text-5xl font-black">
              Featured <span className="text-gradient-primary">Games</span>
            </h2>
            <p className="text-muted-foreground mt-2">Trending titles in the arcade right now.</p>
          </div>
          <Button asChild variant="ghost" className="text-neon-teal hover:text-neon-teal hover:bg-neon-teal/10">
            <Link to="/games">All games <ArrowRight className="ml-2 h-4 w-4" /></Link>
          </Button>
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {featured.map((g) => <GameCard key={g.id} game={g} />)}
        </div>
      </section>

      {/* CTA */}
      <section className="container pb-20">
        <div className="glass-panel rounded-2xl p-10 md:p-16 text-center relative overflow-hidden">
          <div className="absolute inset-0 grid-bg opacity-20" />
          <div className="relative space-y-5 max-w-2xl mx-auto">
            <h2 className="font-display text-3xl md:text-5xl font-black">
              Ready to <span className="text-gradient-accent">level up?</span>
            </h2>
            <p className="text-muted-foreground">
              Connect your wallet to start earning rewards, climb the leaderboard, and unlock exclusive cosmetics.
            </p>
            <div className="flex flex-wrap justify-center gap-4 pt-2">
              <Button size="lg" className="bg-gradient-accent text-accent-foreground font-bold uppercase tracking-wider hover:shadow-glow-green">
                Get Started
              </Button>
              <Button asChild size="lg" variant="outline" className="border-border uppercase tracking-wider">
                <Link to="/shop">Browse Shop</Link>
              </Button>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
};

export default Home;
