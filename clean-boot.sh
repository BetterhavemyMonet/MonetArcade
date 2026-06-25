#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "🧹 Cleaning MonetArcade broken build state..."

cd ~/MonetArcade || exit 1

# Kill any running node processes (prevents port + lock issues)
pkill node || true

# Remove broken installs + caches
rm -rf node_modules
rm -rf package-lock.json
rm -rf node_modules/.vite

# Remove SWC remnants if present
npm remove @swc/core || true

# Clean npm cache
npm cache clean --force

echo "📦 Reinstalling dependencies (Termux-safe)..."

npm install --legacy-peer-deps

echo "🧠 Verifying SWC is NOT installed..."

npm ls @swc/core || echo "✅ SWC not present (good)"

echo "⚙️ Ensuring safe Vite config..."

cat > vite.config.ts << 'EOT'
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": "/src",
    },
  },
});
EOT

echo "🚀 Starting dev server..."

npm run dev
