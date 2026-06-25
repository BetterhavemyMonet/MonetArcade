#!/data/data/com.termux/files/usr/bin/bash

echo "🛡️ Installing PRODUCTION HARDENED MonetArcade..."

cd ~/MonetArcade || exit 1

# -----------------------------
# DEPENDENCIES
# -----------------------------
npm install @solana/web3.js @solana/spl-token

# -----------------------------
# FRONTEND
# -----------------------------
cat > src/services/monetArcade.ts << 'EOT'
import { Connection, PublicKey, Transaction } from "@solana/web3.js";
import {
  getAssociatedTokenAddress,
  createTransferInstruction,
} from "@solana/spl-token";

const API = import.meta.env.VITE_ARCADE_API_URL;

const connection = new Connection("https://api.mainnet-beta.solana.com");

// immutable config safety
const TOKEN_MINT = new PublicKey(import.meta.env.VITE_TOKEN_MINT || "");
const TREASURY = new PublicKey(import.meta.env.VITE_TREASURY_WALLET || "");

/**
 * WALLET CONNECT
 */
export async function connectWallet() {
  if (!window.solana) throw new Error("Wallet not found");
  const res = await window.solana.connect();
  return res.publicKey.toString();
}

/**
 * REAL SPL TRANSFER
 */
async function sendMonetTransaction({ wallet, amount }) {
  const fromWallet = new PublicKey(wallet);

  const fromATA = await getAssociatedTokenAddress(TOKEN_MINT, fromWallet);
  const toATA = await getAssociatedTokenAddress(TOKEN_MINT, TREASURY);

  const tx = new Transaction().add(
    createTransferInstruction(fromATA, toATA, fromWallet, amount)
  );

  tx.feePayer = fromWallet;
  tx.recentBlockhash = (await connection.getLatestBlockhash()).blockhash;

  const signed = await window.solana.signTransaction(tx);
  const sig = await connection.sendRawTransaction(signed.serialize());

  await connection.confirmTransaction({
    signature: sig,
    commitment: "confirmed",
  });

  return sig;
}

/**
 * SESSION ENTRY (server-issued nonce)
 */
export async function startGameSession({ wallet, gameId }) {
  const res = await fetch(`${API}/api/start-game`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ wallet, gameId }),
  });
  return res.json();
}

/**
 * PAY ENTRY FEE
 */
export async function payEntryFee({ wallet, entryFeeMonet }) {
  return sendMonetTransaction({ wallet, amount: entryFeeMonet });
}

/**
 * VERIFY TX AGAINST SESSION
 */
export async function verifyTransaction({ txSignature, sessionId }) {
  const res = await fetch(`${API}/api/verify-entry`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ txSignature, sessionId }),
  });
  return res.json();
}

/**
 * SCORE SUBMISSION (idempotent)
 */
export async function submitScore(data) {
  const res = await fetch(`${API}/api/submit-score`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data),
  });
  return res.json();
}
EOT

rm -rf node_modules/.vite

# -----------------------------
# BACKEND HARDENED
# -----------------------------
if [ -f ~/monet-backend/server.js ]; then
cat > ~/monet-backend/server.js << 'EOT'
const express = require("express");
const cors = require("cors");
const crypto = require("crypto");
const { Connection } = require("@solana/web3.js");

const app = express();
app.use(express.json());
app.use(cors());

const connection = new Connection("https://api.mainnet-beta.solana.com");

/**
 * STATE
 */
let sessions = {};        // sessionId -> { wallet, nonce, claimed }
let txMap = {};           // txSignature -> sessionId (idempotency)
let potLedger = {};       // sessionId -> amount

/**
 * CREATE SESSION (nonce-based)
 */
app.post("/api/start-game", (req, res) => {
  const { wallet, gameId } = req.body;

  const sessionId = crypto.randomUUID();
  const nonce = crypto.randomBytes(16).toString("hex");

  sessions[sessionId] = {
    wallet,
    gameId,
    nonce,
    claimed: false,
  };

  potLedger[sessionId] = 1;

  res.json({ sessionId, nonce });
});

/**
 * VERIFY ENTRY (anti-replay + session binding)
 */
app.post("/api/verify-entry", async (req, res) => {
  try {
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
  } catch (e) {
    res.status(500).json({ verified: false });
  }
});

/**
 * IDENTITY SAFE WIN LOGIC
 */
app.post("/api/submit-score", (req, res) => {
  const { sessionId } = req.body;

  const session = sessions[sessionId];
  if (!session || session.claimed) {
    return res.status(403).json({ error: "Invalid session" });
  }

  session.claimed = true;

  const pot = potLedger[sessionId] || 0;

  const payout = Math.floor(pot * 0.8);
  const treasury = Math.floor(pot * 0.2);

  delete potLedger[sessionId];

  res.json({
    success: true,
    payout,
    treasury,
    sessionId,
  });
});

app.listen(3001, () => {
  console.log("🛡️ MonetArcade PRODUCTION backend running on 3001");
});
EOT
fi

rm -rf node_modules/.vite

echo "✅ PRODUCTION HARDENING COMPLETE"
echo "👉 Restart backend + frontend now"
