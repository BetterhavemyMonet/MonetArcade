// Monet Arcade — backend + Solana service layer.
// Set VITE_ARCADE_API_URL in your environment (.env) to point at the arcade API.
// payEntryFee currently delegates to a placeholder sendMonetTransaction — replace
// with your real Solana SPL transfer (Phantom / @solana/web3.js) implementation.

const API = import.meta.env.VITE_ARCADE_API_URL as string | undefined;

declare global {
  interface Window {
    solana?: {
      connect: () => Promise<{ publicKey: { toString: () => string } }>;
      disconnect?: () => Promise<void>;
      isPhantom?: boolean;
    };
  }
}

export interface MonetPrice {
  priceUsd: number;
  entryFeeMonet: number;
  entryFeeUsd?: number;
}

export interface VerifyResult {
  verified: boolean;
  [k: string]: unknown;
}

export interface SessionResult {
  sessionId: string;
  [k: string]: unknown;
}

function requireApi(): string {
  if (!API) throw new Error("VITE_ARCADE_API_URL is not configured");
  return API;
}

/** Connect Solana wallet — returns the connected wallet address. */
export async function connectWallet(): Promise<string> {
  if (!window.solana) throw new Error("Solana wallet not found");
  const response = await window.solana.connect();
  return response.publicKey.toString();
}

/** Fetch live MONET price and entry fee. */
export async function getMonetPrice(): Promise<MonetPrice> {
  const res = await fetch(`${requireApi()}/api/monet-price`);
  if (!res.ok) throw new Error("Unable to fetch MONET price");
  return res.json();
}

/**
 * Placeholder Solana transfer — wire to @solana/web3.js + SPL token transfer.
 * Must return the on-chain transaction signature.
 */
async function sendMonetTransaction({
  wallet,
  amount,
}: {
  wallet: string;
  amount: number;
}): Promise<string> {
  // INTEGRATION POINT: build + sign + send the SPL token transfer here.
  throw new Error(
    `sendMonetTransaction not implemented (wallet=${wallet}, amount=${amount})`,
  );
}

/** Pay arcade entry fee — amount comes from backend price response. */
export async function payEntryFee({
  wallet,
  entryFeeMonet,
}: {
  wallet: string;
  entryFeeMonet: number;
}): Promise<string> {
  return sendMonetTransaction({ wallet, amount: entryFeeMonet });
}

/** Verify blockchain transaction with the arcade backend. */
export async function verifyTransaction(
  txSignature: string,
): Promise<VerifyResult> {
  const res = await fetch(`${requireApi()}/api/verify-entry`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ txSignature }),
  });
  if (!res.ok) throw new Error("Transaction verification failed");
  return res.json();
}

/** Create playable arcade session. */
export async function startGameSession({
  wallet,
  gameId,
}: {
  wallet: string;
  gameId: string;
}): Promise<SessionResult> {
  const res = await fetch(`${requireApi()}/api/start-game`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ wallet, gameId }),
  });
  return res.json();
}

/** Submit final score for a session. */
export async function submitScore({
  wallet,
  gameId,
  sessionId,
  score,
}: {
  wallet: string;
  gameId: string;
  sessionId: string;
  score: number;
}) {
  const res = await fetch(`${requireApi()}/api/submit-score`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ wallet, gameId, sessionId, score }),
  });
  return res.json();
}
