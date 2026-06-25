#!/data/data/com.termux/files/usr/bin/bash

echo "🏟️ Installing LIVE LOBBY + MULTI-GAME SYSTEM..."

cd ~/monet-backend || exit 1

# -----------------------------
# BACKEND REWRITE (LOBBY SYSTEM)
# -----------------------------
cat > server.js << 'EOT'
const express = require("express");
const cors = require("cors");
const crypto = require("crypto");
const { Connection } = require("@solana/web3.js");

const app = express();
app.use(express.json());
app.use(cors());

const connection = new Connection("https://api.mainnet-beta.solana.com");

/**
 * GAME REGISTRY
 */
const games = {
  mario: { entryFee: 1, players: 0 },
  shooter: { entryFee: 2, players: 0 },
  drift: { entryFee: 1, players: 0 },
  toads: { entryFee: 1, players: 0 },
};

/**
 * STATE
 */
let sessions = {};
let txMap = {};
let potLedger = {};
let onlinePlayers = new Set();

/**
 * LOBBY SNAPSHOT
 */
app.get("/api/lobby", (req, res) => {
  res.json({
    online: onlinePlayers.size,
    games,
    activeSessions: Object.keys(sessions).length,
  });
});

/**
 * START GAME SESSION (multi-game)
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

  onlinePlayers.add(wallet);
  games[gameId].players++;

  potLedger[sessionId] = games[gameId].entryFee;

  res.json({
    sessionId,
    nonce,
    gameId,
    entryFee: games[gameId].entryFee,
  });
});

/**
 * VERIFY ENTRY (anti-replay)
 */
app.post("/api/verify-entry", async (req, res) => {
  const { txSignature, sessionId } = req.body;

  if (txMap[txSignature]) {
    return res.json({ verified: true, replay: true });
  }

  const session = sessions[sessionId];
  if (!session) {
    return res.status(403).json({ verified: false });
  }

  const status = await connection.getSignatureStatus(txSignature);

  if (!status?.value || status.value.err) {
    return res.json({ verified: false });
  }

  txMap[txSignature] = sessionId;

  res.json({ verified: true });
});

/**
 * SUBMIT SCORE (per game leaderboard entry point)
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

  res.json({
    success: true,
    gameId: session.gameId,
    score,
    payout,
    treasury,
  });
});

app.listen(3001, () => {
  console.log("🏟️ Monet LIVE LOBBY running on 3001");
});
EOT

echo "✅ Lobby system installed"
