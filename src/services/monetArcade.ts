// Monet Arcade service layer (RESTORED + STABLE)

const API = import.meta.env.VITE_ARCADE_API_URL as string | undefined;

function requireApi(): string {
  if (!API) throw new Error("VITE_ARCADE_API_URL is not configured");
  return API;
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

/** Connect wallet */
export async function connectWallet(): Promise<string> {
  if (!window.solana) throw new Error("Solana wallet not found");

  const response = await window.solana.connect();
  return response.publicKey.toString();
}

/** Fetch price */
export async function getMonetPrice(): Promise<MonetPrice> {
  const res = await fetch(`${requireApi()}/api/monet-price`);
  if (!res.ok) throw new Error("Unable to fetch MONET price");
  return res.json();
}

/** PLACEHOLDER: blockchain payment */
async function sendMonetTransaction({
  wallet,
  amount,
}: {
  wallet: string;
  amount: number;
}): Promise<string> {
  // TODO: integrate @solana/web3.js SPL transfer
  console.log("mock tx:", wallet, amount);
  return "MOCK_TX_SIGNATURE";
}

/** REQUIRED EXPORT (FIXES YOUR ERROR) */
export async function payEntryFee({
  wallet,
  entryFeeMonet,
}: {
  wallet: string;
  entryFeeMonet: number;
}): Promise<string> {
  return sendMonetTransaction({
    wallet,
    amount: entryFeeMonet,
  });
}

/** Verify tx */
export async function verifyTransaction(txSignature: string) {
  const res = await fetch(`${requireApi()}/api/verify-entry`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ txSignature }),
  });

  if (!res.ok) throw new Error("Verification failed");
  return res.json();
}

/** Start session */
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

/** Submit score */
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
