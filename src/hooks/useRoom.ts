import { useEffect, useRef, useState } from "react";
import { io } from "socket.io-client";

const API = import.meta.env.VITE_ARCADE_API_URL;

export function useRoom(roomId?: string) {
  const socketRef = useRef<any>(null);

  const [players, setPlayers] = useState<string[]>([]);
  const [scores, setScores] = useState<Record<string, number>>({});
  const [status, setStatus] = useState("connecting");

  useEffect(() => {
    if (!roomId) return;

    const socket = io(API);
    socketRef.current = socket;

    socket.emit("room:join", { roomId });

    socket.on("room:state", (data) => {
      setPlayers(data.players || []);
      setScores(data.scores || {});
    });

    socket.on("room:player_joined", (data) => {
      setPlayers((p) => [...new Set([...p, data.wallet])]);
    });

    socket.on("room:score_update", (data) => {
      setScores((s) => ({
        ...s,
        [data.wallet]: data.score,
      }));
    });

    socket.on("room:status", (data) => {
      setStatus(data.status);
    });

    return () => socket.disconnect();
  }, [roomId]);

  const submitScore = (wallet: string, score: number) => {
    socketRef.current?.emit("room:score", {
      roomId,
      wallet,
      score,
    });
  };

  const finishMatch = (wallet: string, score: number) => {
    socketRef.current?.emit("room:finish", {
      roomId,
      wallet,
      score,
    });
  };

  return {
    players,
    scores,
    status,
    submitScore,
    finishMatch,
  };
}
