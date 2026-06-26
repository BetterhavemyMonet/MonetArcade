import { useEffect, useRef, useState } from "react";
import { io } from "socket.io-client";

const API = import.meta.env.VITE_ARCADE_API_URL;

export function useLiveLobby() {
  const socketRef = useRef<any>(null);

  const [connectedPlayers, setConnectedPlayers] = useState(0);
  const [queue, setQueue] = useState<Record<string, number>>({});
  const [status, setStatus] = useState("disconnected");

  useEffect(() => {
    const socket = io(API);
    socketRef.current = socket;

    socket.on("connect", () => {
      setStatus("connected");
    });

    socket.on("disconnect", () => {
      setStatus("disconnected");
    });

    // total online players
    socket.on("lobby:players", (data) => {
      setConnectedPlayers(data.count);
    });

    // queue per game
    socket.on("lobby:queue", (data) => {
      setQueue(data); // { mario: 2, shooter: 5 }
    });

    return () => socket.disconnect();
  }, []);

  return {
    connectedPlayers,
    queue,
    status,
  };
}
