#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "🎮 MonetArcade Final Wiring Script"

PROJECT="$HOME/MonetArcade"

cd "$PROJECT"

echo "📥 Syncing repository..."
git pull origin main || true


echo "📦 Installing frontend dependencies..."
npm install


echo "🔎 Checking required packages..."

PACKAGES=(
"@solana/web3.js"
"@solana/wallet-adapter-base"
"@solana/wallet-adapter-react"
"@solana/wallet-adapter-wallets"
"axios"
"react-router-dom"
)

for pkg in "${PACKAGES[@]}"
do
    npm ls "$pkg" >/dev/null 2>&1 || {
        echo "➕ Installing $pkg"
        npm install "$pkg"
    }
done


echo "🔧 Creating environment connection..."

if [ ! -f .env ]; then
cat > .env <<EOF
VITE_ARCADE_API_URL=http://localhost:5000
VITE_MONET_TOKEN=MONET
EOF

echo "Created .env"
fi


echo "🎴 Searching game files..."

find . -maxdepth 3 \
-type f \
\( -name "*.html" -o -name "*.jsx" -o -name "*.tsx" \) \
| grep -Ei "game|race|mario|tetris|frog|arcade" || true


echo "🧩 Checking backend..."

if [ -f server.js ]; then

echo "Backend detected"

grep -q "/api/monet-price" server.js || \
echo "⚠️ Missing monet-price endpoint"

grep -q "verifyTransaction" server.js || \
echo "⚠️ Missing transaction verification"

else

echo "⚠️ server.js not found"

fi


echo "🎮 Checking game cards..."

if [ -d src ]; then

grep -R "GameCard" src || echo "⚠️ GameCard component not detected"

grep -R "wallet" src || echo "⚠️ Wallet wiring not detected"

fi


echo "🏗️ Building..."

npm run build


echo "🚀 Deploying frontend..."

vercel --prod --yes


echo "🔄 Restarting backend if available..."

pkill -f server.js || true

if [ -f server.js ]; then
nohup node server.js > backend.log 2>&1 &
fi


echo ""
echo "✅ MonetArcade wiring pass complete"
echo "Check:"
echo "- Game cards"
echo "- Wallet connect"
echo "- Payment flow"
echo "- Backend API"
echo "- Vercel deployment"
