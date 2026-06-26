#!/data/data/com.termux/files/usr/bin/bash

echo "⚡ Installing REALTIME LOBBY (Socket.IO)..."

cd ~/monet-backend || exit 1

npm install express socket.io cors @solana/web3.js

cat > server.js << 'EOT'
const express = require("express");
const cors = require("cors");
const crypto = require("crypto");
const { createServer } = require("http");
const { Server } = require("socket.io");
const { Connection } = require("@solana/web3.js");

const app = express();
app.use(express.json());
app.use(cors());

const httpServer = createServer(app);
const io = new Server(httpServer, {
  cors: { origin: "*" },
});

const connection = new Connection("https://api.mainnet-beta.solana.com");

/**
 * GAME STATE
 */
const games = {
  mario: { entryFee: 1, players: 0 },
  shooter: { entryFee: 2, players: 0 },
  drift: { entryFee: 1, players: 0 },
  toads: { entryFee: 1, players: 0 },
};

let sessions = {};
let txMap = {};
let potLedger = {};
let onlinePlayers = new Map();

/**
 * BROADCAST LOBBY STATE
 */
function broadcastLobby() {
  io.emit("lobby:update", {
    online: onlinePlayers.size,
    games,
    activeSessions: Object.keys(sessions).length,
  });
}

/**
 * SOCKET CONNECT
 */
io.on("connection", (socket) => {
  console.log("Player connected:", socket.id);

  onlinePlayers.set(socket.id, { connectedAt: Date.now() });

  broadcastLobby();

  socket.on("disconnect", () => {
    onlinePlayers.delete(socket.id);
    broadcastLobby();
  });
});

/**
 * START GAME
 */
app.post("/api/start-game", (req, res) => {
  const { wallet, gameId } = req.body;

  if (!games[gameId]) {
    return res.status(400).json({ error: "Invalid game" });
  }

  const sessionId = crypto.randomUUID();
  const nonce = crypto.randomBytes(16).toString("hex");

  sessions[sessionId] = {
    wallet,
    gameId,
    nonce,
    claimed: false,
  };

  games[gameId].players++;
  potLedger[sessionId] = games[gameId].entryFee;

  broadcastLobby();

  res.json({
    sessionId,
    nonce,
    gameId,
    entryFee: games[gameId].entryFee,
  });
});

/**
 * VERIFY ENTRY
 */
app.post("/api/verify-entry", async (req, res) => {
  const { txSignature, sessionId } = req.body;

  if (txMap[txSignature]) {
    return res.json({ verified: true, replay: true });
  }

  const session = sessions[sessionId];
  if (!session) return res.status(403).json({ verified: false });

  const status = await connection.getSignatureStatus(txSignature);

  if (!status?.value || status.value.err) {
    return res.json({ verified: false });
  }

  txMap[txSignature] = sessionId;

  res.json({ verified: true });
});

/**
 * SCORE SUBMISSION
 */
app.post("/api/submit-score", (req, res) => {
  const { sessionId, score } = req.body;

  const session = sessions[sessionId];
  if (!session || session.claimed) {
    return res.status(403).json({ error: "Invalid session" });
  }

  session.claimed = true;

  const pot = potLedger[sessionId] || 0;

  const payout = Math.floor(pot * 0.8);
  const treasury = Math.floor(pot * 0.2);

  games[session.gameId].players--;

  delete potLedger[sessionId];

  broadcastLobby();

  res.json({
    success: true,
    gameId: session.gameId,
    score,
    payout,
    treasury,
  });
});

httpServer.listen(3001, () => {
  console.log("⚡ REALTIME LOBBY RUNNING ON 3001");
});
EOT

echo "✅ Realtime lobby installed"
