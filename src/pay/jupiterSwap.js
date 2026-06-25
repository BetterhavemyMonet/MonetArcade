import { Connection, PublicKey } from "@solana/web3.js";
import { Jupiter } from "@jup-ag/core";

const connection = new Connection("https://api.mainnet-beta.solana.com");

// MONET mint
const MONET_MINT = new PublicKey("6eACLGXCGdw9D5zb5eBKyFnFNTX9pTihDEpZQ7gYAX1b");

export async function swapToMonet(wallet, amountIn, inputMint) {
  const jupiter = await Jupiter.load({
    connection,
    cluster: "mainnet-beta",
    user: wallet.publicKey
  });

  const routes = await jupiter.computeRoutes({
    inputMint,
    outputMint: MONET_MINT,
    amount: amountIn,
    slippage: 1
  });

  if (!routes.routesInfos.length) {
    throw new Error("No swap route found");
  }

  const { execute } = await jupiter.exchange({
    routeInfo: routes.routesInfos[0]
  });

  const result = await execute();

  return result.txid;
}
