import { ShoppingCart, Sparkles } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { toast } from "sonner";
import { cn } from "@/lib/utils";

type Rarity = "Common" | "Rare" | "Epic" | "Legendary";

const items: { id: string; name: string; type: string; price: string; rarity: Rarity; emoji: string }[] = [
  { id: "s1", name: "Cyber Visor", type: "Avatar Skin", price: "1,200", rarity: "Epic", emoji: "🕶️" },
  { id: "s2", name: "Plasma Trail", type: "Car Effect", price: "800", rarity: "Rare", emoji: "💨" },
  { id: "s3", name: "Neon Aura", type: "Profile FX", price: "2,400", rarity: "Legendary", emoji: "✨" },
  { id: "s4", name: "Token Multiplier", type: "Boost", price: "500", rarity: "Common", emoji: "⚡" },
  { id: "s5", name: "Holo Banner", type: "Banner", price: "650", rarity: "Rare", emoji: "🏳️" },
  { id: "s6", name: "Phantom Skin", type: "Character", price: "3,200", rarity: "Legendary", emoji: "👻" },
  { id: "s7", name: "XP Booster x2", type: "Boost", price: "400", rarity: "Common", emoji: "🚀" },
  { id: "s8", name: "Toad Companion", type: "Pet", price: "1,800", rarity: "Epic", emoji: "🐸" },
];

const rarityStyles: Record<Rarity, string> = {
  Common: "bg-muted text-muted-foreground border-border",
  Rare: "bg-neon-blue/15 text-neon-blue border-neon-blue/40",
  Epic: "bg-neon-magenta/15 text-neon-magenta border-neon-magenta/40",
  Legendary: "bg-neon-green/15 text-neon-green border-neon-green/40",
};

const Shop = () => {
  const handleBuy = (name: string) => {
    // INTEGRATION POINT: trigger payment / Web3 transaction flow here.
    toast(`Adding ${name} to cart`, { description: "Checkout will be enabled with payments integration." });
  };

  return (
    <div className="container py-12 animate-fade-in">
      <header className="flex flex-col md:flex-row md:items-end md:justify-between gap-4 mb-10">
        <div>
          <h1 className="font-display text-4xl md:text-6xl font-black">
            Arcade <span className="text-gradient-primary">Shop</span>
          </h1>
          <p className="text-muted-foreground mt-2">Cosmetics, boosts, and exclusive digital arcade items.</p>
        </div>
        <div className="glass-panel rounded-xl px-5 py-3 flex items-center gap-3">
          <Sparkles className="text-neon-teal h-5 w-5" />
          <div>
            <p className="text-xs uppercase tracking-wider text-muted-foreground">Balance</p>
            <p className="font-display text-xl font-bold text-gradient-primary">4,250 TOKENS</p>
          </div>
        </div>
      </header>

      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
        {items.map((item) => (
          <article key={item.id} className="glass-panel rounded-xl p-5 hover-glow flex flex-col">
            <div className="aspect-square rounded-lg bg-gradient-to-br from-muted to-card flex items-center justify-center text-6xl mb-4 border border-border">
              <span className="animate-float">{item.emoji}</span>
            </div>
            <Badge className={cn("self-start mb-2 uppercase text-[10px] tracking-widest border", rarityStyles[item.rarity])}>
              {item.rarity}
            </Badge>
            <h3 className="font-display text-lg leading-tight">{item.name}</h3>
            <p className="text-xs text-muted-foreground">{item.type}</p>
            <div className="mt-auto pt-4 flex items-center justify-between gap-2">
              <span className="font-display text-lg text-neon-teal">{item.price}</span>
              <Button
                size="sm"
                onClick={() => handleBuy(item.name)}
                className="bg-gradient-primary text-primary-foreground font-semibold hover:shadow-glow-teal"
              >
                <ShoppingCart className="h-4 w-4" />
              </Button>
            </div>
          </article>
        ))}
      </div>
    </div>
  );
};

export default Shop;
