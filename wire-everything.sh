#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "🎮 MonetArcade Full Wiring Pass"

cd ~/MonetArcade

echo "📦 Installing required dependencies..."

npm install \
@solana/web3.js \
@solana/wallet-adapter-base \
@solana/wallet-adapter-react \
@solana/wallet-adapter-wallets \
axios \
react-router-dom \
--legacy-peer-deps


echo "🔍 Checking arcade components..."

FILES=(
"src/components/GameCard.tsx"
"src/components/GameCard.jsx"
"src/context/WalletContext.tsx"
"src/services/monetArcade.ts"
"src/data/games.ts"
"src/pages/Games.tsx"
)

for f in "${FILES[@]}"
do
    if [ -f "$f" ]; then
        echo "✅ Found $f"
    else
        echo "⚠️ Missing $f"
    fi
done


echo "🔗 Checking wallet imports..."

grep -R "@solana/wallet-adapter" src || echo "⚠️ Wallet adapter imports missing"


echo "🎴 Checking game registry..."

grep -R "GameCard" src/data src/pages src/components || true


echo "🌐 Checking API connection..."

if [ ! -f .env ]; then
cat > .env <<EOF
VITE_ARCADE_API_URL=http://localhost:5000
EOF
echo "Created .env"
fi


echo "🧹 Fixing Google font CSS placement..."

CSS=$(grep -rl "fonts.googleapis.com" src 2>/dev/null | head -1 || true)

if [ -n "$CSS" ]; then
IMPORT=$(grep "@import" "$CSS" | head -1 || true)

if [ -n "$IMPORT" ]; then
sed -i "/fonts.googleapis.com/d" "$CSS"
sed -i "1i $IMPORT" "$CSS"
echo "Fixed CSS import"
fi
fi


echo "🏗️ Building..."

npm run build


echo "💾 Saving changes..."

git add .

git commit -m "Automated MonetArcade wiring pass" || true


echo "✅ Wiring pass complete"
