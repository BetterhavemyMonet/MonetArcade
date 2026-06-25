import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";

const NotFound = () => (
  <div className="min-h-screen flex flex-col items-center justify-center text-center p-6">
    <h1 className="font-display text-7xl md:text-9xl font-black text-gradient-primary animate-pulse-glow">404</h1>
    <p className="text-muted-foreground mt-4 mb-8 uppercase tracking-widest">Signal lost in the neon void</p>
    <Button asChild className="bg-gradient-primary text-primary-foreground font-bold uppercase">
      <Link to="/">Return to Arcade</Link>
    </Button>
  </div>
);

export default NotFound;
