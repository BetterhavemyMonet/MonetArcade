#!/data/data/com.termux/files/usr/bin/bash

echo "🔧 Fixing MonetArcade build..."

FILE="src/services/monetArcade.ts"

# Ensure verifyTransaction exists (append only if missing)
grep -q "verifyTransaction" "$FILE"
if [ $? -ne 0 ]; then
cat >> "$FILE" << 'EOT'

export async function verifyTransaction(txSignature: string) {
  const res = await fetch(`${API}/api/verify-entry`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ txSignature })
  });

  if (!res.ok) throw new Error("Transaction verification failed");

  return res.json();
}
EOT
fi

echo "🧹 Clearing Vite cache..."
rm -rf node_modules/.vite

echo "🚀 Starting dev server..."
npm run dev
