import { createContext, useCallback, useContext, useState } from "react";
import { connectWallet as svcConnect } from "@/services/monetArcade";

const Ctx = createContext(null);

export const WalletProvider = ({ children }) => {
  const [wallet, setWallet] = useState(null);
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
    window.solana?.disconnect?.();
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
  if (!ctx) throw new Error("Wallet missing provider");
  return ctx;
};
