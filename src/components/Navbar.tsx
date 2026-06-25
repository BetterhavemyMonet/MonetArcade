import { useState } from "react";
import { NavLink } from "react-router-dom";
import { Menu, X } from "lucide-react";
import Logo from "./Logo";
import WalletButton from "./WalletButton";
import { cn } from "@/lib/utils";

const navItems = [
  { label: "Home", to: "/" },
  { label: "Games", to: "/games" },
  { label: "Tournaments", to: "/tournaments" },
  { label: "Shop", to: "/shop" },
  { label: "Profile", to: "/profile" },
];

const Navbar = () => {
  const [open, setOpen] = useState(false);
  return (
    <header className="fixed top-0 inset-x-0 z-50 backdrop-blur-xl bg-background/70 border-b border-border">
      <div className="container flex items-center justify-between h-20">
        <Logo />

        <nav className="hidden md:flex items-center gap-1">
          {navItems.map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.to === "/"}
              className={({ isActive }) =>
                cn(
                  "px-4 py-2 rounded-md text-sm font-semibold tracking-wide uppercase transition-all",
                  isActive
                    ? "text-neon-teal bg-muted shadow-glow-teal"
                    : "text-muted-foreground hover:text-foreground hover:bg-muted/50"
                )
              }
            >
              {item.label}
            </NavLink>
          ))}
        </nav>

        <div className="hidden md:block">
          <WalletButton />
        </div>

        <button
          className="md:hidden text-foreground"
          onClick={() => setOpen(!open)}
          aria-label="Toggle menu"
        >
          {open ? <X /> : <Menu />}
        </button>
      </div>

      {open && (
        <div className="md:hidden border-t border-border bg-background/95 animate-fade-in">
          <nav className="container py-4 flex flex-col gap-2">
            {navItems.map((item) => (
              <NavLink
                key={item.to}
                to={item.to}
                end={item.to === "/"}
                onClick={() => setOpen(false)}
                className={({ isActive }) =>
                  cn(
                    "px-4 py-3 rounded-md font-semibold uppercase tracking-wide",
                    isActive ? "text-neon-teal bg-muted" : "text-muted-foreground"
                  )
                }
              >
                {item.label}
              </NavLink>
            ))}
            <div className="pt-2"><WalletButton /></div>
          </nav>
        </div>
      )}
    </header>
  );
};

export default Navbar;
