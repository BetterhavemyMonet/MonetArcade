import { useEffect, useState } from "react";
import { io } from "socket.io-client";

const socket = io(import.meta.env.VITE_ARCADE_API_URL);

export function useLobby() {
  const [lobby, setLobby] = useState<any>({});

  useEffect(() => {
    socket.on("lobby:update", setLobby);
    return () => {
      socket.off("lobby:update");
    };
  }, []);

  return lobby;
}
