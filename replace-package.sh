#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "🎮 Rebuilding MonetArcade package setup..."

cd ~/MonetArcade

echo "📦 Backing up current package.json..."
cp package.json package.json.backup

echo "📝 Writing clean package.json..."

cat > package.json <<'EOF'
{
  "name": "monet-arcade",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "@solana/web3.js": "^1.95.8",
    "@solana/wallet-adapter-base": "^0.9.23",
    "@solana/wallet-adapter-react": "^0.15.35",
    "@solana/wallet-adapter-react-ui": "^0.9.35",
    "@solana/wallet-adapter-wallets": "^0.19.32",
    "@tanstack/react-query": "^5.0.0",
    "clsx": "^2.1.1",
    "lucide-react": "^0.468.0",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "tailwind-merge": "^2.5.5"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.3.4",
    "autoprefixer": "^10.4.20",
    "postcss": "^8.4.49",
    "tailwindcss": "^3.4.17",
    "typescript": "^5.7.2",
    "vite": "^5.4.19"
  }
}
EOF

echo "🧹 Removing old dependencies..."
rm -rf node_modules
rm -f package-lock.json

echo "📦 Installing clean dependencies..."
npm install --legacy-peer-deps

echo "🔍 Checking Vite..."
npm ls vite @vitejs/plugin-react

echo "🚀 Starting MonetArcade..."
npm run dev
