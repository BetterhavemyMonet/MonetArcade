#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "🛠 Repairing MonetArcade..."

cd ~/MonetArcade

echo "1) Removing accidental embedded repo..."

git rm --cached velvet-game-glow 2>/dev/null || true
rm -rf velvet-game-glow

echo "2) Fixing git branch..."

git checkout -B main

echo "3) Installing dependencies..."

npm install --legacy-peer-deps

echo "4) Ensuring Vite exists..."

npm install -D vite @vitejs/plugin-react --legacy-peer-deps

echo "5) Checking package..."

npm ls vite @vitejs/plugin-react

echo "6) Saving repair..."

git add .
git commit -m "Repair MonetArcade repository structure" || true

echo "7) Push..."

git push -u origin main || true

echo ""
echo "✅ Repair complete"
echo "Run:"
echo "cd ~/MonetArcade && npm run dev"
