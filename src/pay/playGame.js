import { PublicKey, Transaction } from "@solana/web3.js";
import { getAssociatedTokenAddress, createTransferInstruction } from "@solana/spl-token";

const MONET_MINT = new PublicKey("6eACLGXCGdw9D5zb5eBKyFnFNTX9pTihDEpZQ7gYAX1b");
const TREASURY = new PublicKey("REPLACE_TREASURY_WALLET");

const COST = 100 * 1_000_000;

export async function playGame(gameId, wallet, connection) {
  if (!wallet?.publicKey) {
    alert("Connect wallet first");
    return;
  }

  const user = wallet.publicKey;

  const userATA = await getAssociatedTokenAddress(MONET_MINT, user);
  const treasuryATA = await getAssociatedTokenAddress(MONET_MINT, TREASURY);

  const tx = new Transaction().add(
    createTransferInstruction(userATA, treasuryATA, user, COST)
  );

  tx.feePayer = user;

  const { blockhash } = await connection.getLatestBlockhash();
  tx.recentBlockhash = blockhash;

  const signed = await wallet.signTransaction(tx);
  const sig = await connection.sendRawTransaction(signed.serialize());

  await connection.confirmTransaction(sig, "confirmed");

  const res = await fetch("http://localhost:5000/api/play", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      wallet: user.toString(),
      txSignature: sig,
      gameId
    })
  });

  const data = await res.json();

  if (!res.ok) {
    alert(data.error || "Payment failed");
    return;
  }

  window.location.href = `/game/${gameId}`;
}
