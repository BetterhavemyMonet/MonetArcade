import { Wallet, LogOut } from "lucide-react";
import { Button } from "@/components/ui/button";
import { toast } from "sonner";
import { useWallet } from "@/context/WalletContext";

const short = (a: string) => `${a.slice(0, 4)}…${a.slice(-4)}`;

const WalletButton = () => {
  const { wallet, connecting, connect, disconnect } = useWallet();

  const handleConnect = async () => {
    try {
      const addr = await connect();
      toast.success("Wallet connected", { description: short(addr) });
    } catch (e) {
      toast.error("Connection failed", {
        description: e instanceof Error ? e.message : "Unable to connect wallet",
      });
    }
  };

  if (wallet) {
    return (
      <Button
        onClick={disconnect}
        variant="outline"
        className="border-neon-teal/40 text-neon-teal hover:bg-neon-teal/10 hover:text-neon-teal font-mono"
      >
        <Wallet className="h-4 w-4 mr-2" />
        {short(wallet)}
        <LogOut className="h-3 w-3 ml-2 opacity-60" />
      </Button>
    );
  }

  return (
    <Button
      onClick={handleConnect}
      disabled={connecting}
      className="bg-gradient-primary text-primary-foreground font-semibold hover:shadow-glow-teal transition-all border border-neon-teal/40"
    >
      <Wallet className="h-4 w-4 mr-2" />
      {connecting ? "Connecting…" : "Connect Wallet"}
    </Button>
  );
};

export default WalletButton;
