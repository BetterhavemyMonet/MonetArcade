#!/bin/bash

set -e

echo "🚀 Monet Arcade FULL DEPLOY PIPELINE STARTING..."

# ----------------------------
# CONFIG (edit if needed)
# ----------------------------
BRANCH="main"
APP_NAME="Monet Arcade"

# ----------------------------
# 1. Cleanup environment
# ----------------------------
echo "🧹 Cleaning environment..."

pkill -f node || true
pkill -f vite || true

rm -rf node_modules
rm -rf dist
rm -f package-lock.json

npm cache clean --force

# ----------------------------
# 2. Install stable dependencies
# ----------------------------
echo "📦 Installing dependencies (stable Solana stack)..."

npm install \
react react-dom \
@solana/web3.js \
@solana/wallet-adapter-base \
@solana/wallet-adapter-react \
@solana/wallet-adapter-react-ui \
@solana/wallet-adapter-wallets \
--legacy-peer-deps

npm install -D vite @vitejs/plugin-react --legacy-peer-deps

# ----------------------------
# 3. Build production bundle
# ----------------------------
echo "🏗️ Building production bundle..."

npm run build

if [ ! -d "dist" ]; then
  echo "❌ Build failed: dist/ missing"
  exit 1
fi

echo "✅ Build complete"

# ----------------------------
# 4. Git validation
# ----------------------------
echo "🔗 Preparing Git deploy..."

if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "❌ Not a git repo"
  exit 1
fi

git add .

echo "📝 Committing changes..."
git commit -m "🚀 Arcade production deploy $(date)" || echo "No changes to commit"

echo "⬆️ Pushing to $BRANCH..."
git push origin $BRANCH

# ----------------------------
# 5. Vercel deploy trigger
# ----------------------------
echo "🌐 Triggering Vercel deploy..."

if command -v vercel >/dev/null 2>&1; then
  vercel --prod --yes
else
  echo "⚠️ Vercel CLI not found — skipping direct deploy"
fi

# ----------------------------
# 6. Post-deploy health check
# ----------------------------
echo "🧪 Running health check..."

sleep 10

URL="https://betterhavemymonet.com"

HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" $URL || echo "000")

if [ "$HTTP_STATUS" -eq 200 ]; then
  echo "✅ DEPLOY SUCCESS — Arcade is live!"
else
  echo "⚠️ WARNING: Site returned status $HTTP_STATUS"
fi

# ----------------------------
# 7. Finish
# ----------------------------
echo ""
echo "🎮 $APP_NAME DEPLOYMENT COMPLETE"
echo "🌐 Live URL: $URL"
echo "🏁 Pipeline finished"
