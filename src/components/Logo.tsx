import { Gamepad2 } from "lucide-react";
import { Link } from "react-router-dom";

const Logo = ({ size = "md" }: { size?: "sm" | "md" | "lg" }) => {
  const sizes = {
    sm: "text-lg",
    md: "text-2xl",
    lg: "text-5xl md:text-7xl",
  };
  return (
    <Link to="/" className="flex items-center gap-2 group">
      <div className="relative">
        <Gamepad2 className="h-7 w-7 text-neon-teal group-hover:animate-pulse" strokeWidth={2.5} />
        <div className="absolute inset-0 blur-md bg-neon-teal/40 -z-10" />
      </div>
      <span className={`font-display font-black tracking-wider ${sizes[size]} text-gradient-primary`}>
        MONET<span className="text-neon-green">.</span>ARCADE
      </span>
    </Link>
  );
};

export default Logo;
