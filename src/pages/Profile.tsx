import { Trophy, Star, Zap, Target, Award, Gift } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import avatar from "@/assets/avatar.jpg";

const stats = [
  { label: "Total Wins", value: "248", icon: Trophy, color: "text-neon-green" },
  { label: "Win Rate", value: "67%", icon: Target, color: "text-neon-teal" },
  { label: "XP", value: "12,450", icon: Zap, color: "text-neon-blue" },
  { label: "Rank", value: "#142", icon: Star, color: "text-neon-magenta" },
];

const achievements = [
  { title: "First Blood", desc: "Win your first match", unlocked: true },
  { title: "Drift King", desc: "Win 10 Monet Drift races", unlocked: true },
  { title: "Token Hoarder", desc: "Collect 1,000 tokens", unlocked: true },
  { title: "Tournament Champion", desc: "Win a tournament", unlocked: false },
  { title: "Untouchable", desc: "10-game win streak", unlocked: false },
  { title: "Legend", desc: "Reach top 10 globally", unlocked: false },
];

const leaderboard = [
  { rank: 140, name: "ShadowByte", xp: 12_820 },
  { rank: 141, name: "NeonRyder", xp: 12_640 },
  { rank: 142, name: "You", xp: 12_450, you: true },
  { rank: 143, name: "PixelMonk", xp: 12_310 },
  { rank: 144, name: "CryoFox", xp: 12_180 },
];

const Profile = () => (
  <div className="container py-12 animate-fade-in space-y-10">
    {/* Header */}
    <section className="glass-panel rounded-2xl p-6 md:p-10 grid md:grid-cols-[auto_1fr_auto] gap-6 items-center relative overflow-hidden">
      <div className="absolute inset-0 grid-bg opacity-20" />
      <div className="relative">
        <div className="w-28 h-28 md:w-36 md:h-36 rounded-2xl overflow-hidden border-2 border-neon-teal shadow-glow-teal">
          <img src={avatar} alt="Player avatar" width={512} height={512} className="w-full h-full object-cover" />
        </div>
      </div>
      <div className="relative space-y-2">
        <Badge className="bg-neon-green/15 text-neon-green border-neon-green/40 uppercase tracking-widest">Online</Badge>
        <h1 className="font-display text-3xl md:text-5xl font-black">PlayerOne_42</h1>
        <p className="text-muted-foreground">Joined March 2025 · Level 24 Arcade Drifter</p>
        <div className="max-w-md space-y-1">
          <div className="flex justify-between text-xs text-muted-foreground">
            <span>Level 24</span><span>2,450 / 5,000 XP</span>
          </div>
          <Progress value={49} className="h-2 bg-muted" />
        </div>
      </div>
      <div className="relative">
        <Button variant="outline" className="border-neon-teal/40 text-neon-teal hover:bg-neon-teal/10">
          Edit Profile
        </Button>
      </div>
    </section>

    {/* Stats */}
    <section className="grid grid-cols-2 md:grid-cols-4 gap-4">
      {stats.map((s) => (
        <div key={s.label} className="glass-panel rounded-xl p-5 hover-glow">
          <s.icon className={`h-6 w-6 ${s.color} mb-3`} />
          <div className="font-display text-3xl font-black">{s.value}</div>
          <div className="text-xs uppercase tracking-wider text-muted-foreground">{s.label}</div>
        </div>
      ))}
    </section>

    <div className="grid lg:grid-cols-3 gap-8">
      {/* Achievements */}
      <section className="lg:col-span-2 space-y-4">
        <h2 className="font-display text-2xl flex items-center gap-2">
          <Award className="text-neon-teal" /> Achievements
        </h2>
        <div className="grid sm:grid-cols-2 gap-4">
          {achievements.map((a) => (
            <div
              key={a.title}
              className={`glass-panel rounded-xl p-4 flex gap-4 items-center ${a.unlocked ? "border-neon-teal/40" : "opacity-50"}`}
            >
              <div className={`h-12 w-12 rounded-lg flex items-center justify-center ${a.unlocked ? "bg-gradient-primary shadow-glow-teal" : "bg-muted"}`}>
                <Trophy className={`h-6 w-6 ${a.unlocked ? "text-background" : "text-muted-foreground"}`} />
              </div>
              <div>
                <div className="font-semibold">{a.title}</div>
                <div className="text-xs text-muted-foreground">{a.desc}</div>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Leaderboard */}
      <section className="space-y-4">
        <h2 className="font-display text-2xl flex items-center gap-2">
          <Trophy className="text-neon-green" /> Leaderboard
        </h2>
        <div className="glass-panel rounded-xl divide-y divide-border overflow-hidden">
          {leaderboard.map((p) => (
            <div
              key={p.rank}
              className={`flex items-center justify-between px-4 py-3 ${p.you ? "bg-neon-teal/10 border-l-2 border-neon-teal" : ""}`}
            >
              <div className="flex items-center gap-3">
                <span className="font-display text-sm w-10 text-muted-foreground">#{p.rank}</span>
                <span className={`font-semibold ${p.you ? "text-neon-teal" : ""}`}>{p.name}</span>
              </div>
              <span className="text-xs text-muted-foreground tabular-nums">{p.xp.toLocaleString()} XP</span>
            </div>
          ))}
        </div>

        {/* Rewards */}
        <h2 className="font-display text-2xl flex items-center gap-2 pt-4">
          <Gift className="text-neon-magenta" /> Rewards
        </h2>
        <div className="glass-panel rounded-xl p-5 space-y-3">
          <div className="flex justify-between"><span className="text-muted-foreground">Daily Bonus</span><Badge className="bg-neon-green/15 text-neon-green border-neon-green/40">Ready</Badge></div>
          <div className="flex justify-between"><span className="text-muted-foreground">Weekly Crate</span><span className="text-xs text-muted-foreground">3d 12h</span></div>
          <div className="flex justify-between"><span className="text-muted-foreground">Season Pass</span><Badge variant="outline">Tier 8</Badge></div>
          <Button className="w-full bg-gradient-accent text-accent-foreground font-bold uppercase mt-2">Claim Rewards</Button>
        </div>
      </section>
    </div>
  </div>
);

export default Profile;
