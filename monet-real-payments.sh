#!/data/data/com.termux/files/usr/bin/bash

echo "🚀 Installing real Solana payment system..."

cd ~/MonetArcade || exit 1

# -----------------------------
# DEPENDENCIES
# -----------------------------
npm install @solana/web3.js @solana/spl-token

# -----------------------------
# ENV SAFETY CHECK
# -----------------------------
if [ ! -f .env ]; then
  touch .env
fi

grep -q "VITE_ARCADE_API_URL" .env || echo "VITE_ARCADE_API_URL=http://localhost:3001" >> .env
grep -q "VITE_TOKEN_MINT" .env || echo "VITE_TOKEN_MINT=REPLACE_ME" >> .env
grep -q "VITE_TREASURY_WALLET" .env || echo "VITE_TREASURY_WALLET=REPLACE_ME" >> .env

# -----------------------------
# FRONTEND PATCH
# -----------------------------
cat > src/services/monetArcade.ts << 'EOT'
import { Connection, PublicKey, Transaction } from "@solana/web3.js";
import {
  getAssociatedTokenAddress,
  createTransferInstruction,
} from "@solana/spl-token";

const API = import.meta.env.VITE_ARCADE_API_URL;

const connection = new Connection("https://api.mainnet-beta.solana.com");

const TOKEN_MINT = new PublicKey(import.meta.env.VITE_TOKEN_MINT || "");
const TREASURY = new PublicKey(import.meta.env.VITE_TREASURY_WALLET || "");

export async function connectWallet() {
  if (!window.solana) throw new Error("Wallet not found");
  const res = await window.solana.connect();
  return res.publicKey.toString();
}

async function sendMonetTransaction({ wallet, amount }) {
  if (!window.solana) throw new Error("Wallet not found");

  const fromWallet = new PublicKey(wallet);

  const fromATA = await getAssociatedTokenAddress(TOKEN_MINT, fromWallet);
  const toATA = await getAssociatedTokenAddress(TOKEN_MINT, TREASURY);

  const tx = new Transaction().add(
    createTransferInstruction(
      fromATA,
      toATA,
      fromWallet,
      amount
    )
  );

  tx.feePayer = fromWallet;
  tx.recentBlockhash = (await connection.getLatestBlockhash()).blockhash;

  const signed = await window.solana.signTransaction(tx);
  const sig = await connection.sendRawTransaction(signed.serialize());

  await connection.confirmTransaction(sig);

  return sig;
}

export async function payEntryFee({ wallet, entryFeeMonet }) {
  return sendMonetTransaction({ wallet, amount: entryFeeMonet });
}

export async function verifyTransaction(txSignature) {
  const res = await fetch(`${API}/api/verify-entry`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ txSignature })
  });

  return res.json();
}

export async function getMonetPrice() {
  const res = await fetch(`${API}/api/monet-price`);
  return res.json();
}

export async function startGameSession(data) {
  const res = await fetch(`${API}/api/start-game`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data)
  });
  return res.json();
}

export async function submitScore(data) {
  const res = await fetch(`${API}/api/submit-score`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(data)
  });
  return res.json();
}
EOT

# -----------------------------
# CLEAN VITE CACHE
# -----------------------------
rm -rf node_modules/.vite

# -----------------------------
# BACKEND PATCH (VERIFY FIX)
# -----------------------------
if [ -f ~/monet-backend/server.js ]; then
cat > ~/monet-backend/server.js << 'EOT'
const express = require("express");
const cors = require("cors");
const { Connection } = require("@solana/web3.js");

const app = express();
app.use(express.json());
app.use(cors());

const connection = new Connection("https://api.mainnet-beta.solana.com");

let sessions = {};
let pot = 0;

app.get("/api/monet-price", (req, res) => {
  res.json({ priceUsd: 0.99, entryFeeMonet: 1, entryFeeUsd: 0.99 });
});

app.post("/api/start-game", (req, res) => {
  const { wallet } = req.body;
  const sessionId = Math.random().toString(36).slice(2);

  sessions[sessionId] = { wallet, valid: true, claimed: false };
  pot += 1;

  res.json({ sessionId, pot });
});

app.post("/api/verify-entry", async (req, res) => {
  try {
    const { txSignature } = req.body;

    const status = await connection.getSignatureStatus(txSignature);

    if (!status?.value || status.value.err) {
      return res.json({ verified: false });
    }

    res.json({ verified: true });
  } catch (e) {
    res.status(500).json({ verified: false });
  }
});

app.post("/api/submit-score", (req, res) => {
  const { sessionId } = req.body;
  const session = sessions[sessionId];

  if (!session || session.claimed) {
    return res.status(403).json({ error: "Invalid session" });
  }

  session.claimed = true;

  const payout = Math.floor(pot * 0.8);
  const treasury = Math.floor(pot * 0.2);

  pot = 0;

  res.json({ success: true, payout, treasury });
});

app.listen(3001, () => {
  console.log("🚀 Monet backend running on 3001");
});
EOT
fi

# -----------------------------
# DONE
# -----------------------------
echo "✅ Real payment system installed"
echo "👉 NEXT: set TOKEN_MINT + TREASURY in .env"
echo "👉 RUN: cd ~/monet-backend && npm install @solana/web3.js"
