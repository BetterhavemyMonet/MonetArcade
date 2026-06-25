import Logo from "./Logo";

const Footer = () => (
  <footer className="border-t border-border mt-20 bg-background/70 backdrop-blur">
    <div className="container py-12 grid gap-8 md:grid-cols-4">
      <div className="md:col-span-2">
        <Logo />
        <p className="mt-4 text-muted-foreground max-w-md">
          The futuristic neon arcade. Compete, win, and collect on a Web3-ready
          gaming platform built for the next generation of players.
        </p>
      </div>
      <div>
        <h4 className="font-display text-sm uppercase tracking-widest text-neon-teal mb-3">Platform</h4>
        <ul className="space-y-2 text-muted-foreground text-sm">
          <li>Games</li><li>Tournaments</li><li>Leaderboards</li><li>Shop</li>
        </ul>
      </div>
      <div>
        <h4 className="font-display text-sm uppercase tracking-widest text-neon-teal mb-3">Community</h4>
        <ul className="space-y-2 text-muted-foreground text-sm">
          <li>Discord</li><li>Twitter</li><li>Docs</li><li>Support</li>
        </ul>
      </div>
    </div>
    <div className="border-t border-border py-6 text-center text-xs text-muted-foreground">
      © {new Date().getFullYear()} Monet Arcade. All rights reserved.
    </div>
  </footer>
);

export default Footer;
