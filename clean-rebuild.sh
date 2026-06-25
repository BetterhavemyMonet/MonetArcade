#!/bin/bash

echo "🧹 Cleaning Monet Arcade (dependency reset mode)..."

# kill running processes
pkill -f node || true
pkill -f vite || true
pkill -f npm || true

echo "🧨 Removing broken installs..."
rm -rf node_modules
rm -f package-lock.json

echo "🧽 Clearing npm cache..."
npm cache clean --force

echo "📦 Installing clean core stack..."

npm install \
react react-dom \
@solana/web3.js \
@solana/wallet-adapter-base \
@solana/wallet-adapter-react \
@solana/wallet-adapter-react-ui \
@solana/wallet-adapter-wallets \
-vite @vitejs/plugin-react \
--legacy-peer-deps

echo "⚡ Ensuring Vite exists..."
npm install -D vite @vitejs/plugin-react --legacy-peer-deps

echo "🎮 Done. Starting dev server..."

npm run dev
