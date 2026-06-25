import { createContext, useCallback, useContext, useState, ReactNode } from "react";
import { connectWallet as svcConnect } from "@/services/monetArcade";

interface WalletCtx {
  wallet: string | null;
  connecting: boolean;
  connect: () => Promise<string>;
  disconnect: () => void;
}

const Ctx = createContext<WalletCtx | undefined>(undefined);

export const WalletProvider = ({ children }: { children: ReactNode }) => {
  const [wallet, setWallet] = useState<string | null>(null);
  const [connecting, setConnecting] = useState(false);

  const connect = useCallback(async () => {
    setConnecting(true);
    try {
      const addr = await svcConnect();
      setWallet(addr);
      return addr;
    } finally {
      setConnecting(false);
    }
  }, []);

  const disconnect = useCallback(() => {
    window.solana?.disconnect?.().catch(() => {});
    setWallet(null);
  }, []);

  return (
    <Ctx.Provider value={{ wallet, connecting, connect, disconnect }}>
      {children}
    </Ctx.Provider>
  );
};

export const useWallet = () => {
  const ctx = useContext(Ctx);
  if (!ctx) throw new Error("useWallet must be used within WalletProvider");
  return ctx;
};
