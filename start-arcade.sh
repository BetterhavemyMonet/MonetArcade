#!/bin/bash

echo "🎮 Starting Monet Arcade (Stable Mode)..."

# Kill old processes on ports
fuser -k 5173/tcp 2>/dev/null
fuser -k 5000/tcp 2>/dev/null

# Start backend if exists
if [ -f ~/monet-backend/server.js ]; then
  echo "🚀 Starting backend..."
  cd ~/monet-backend && node server.js &
fi

# Start frontend
echo "🎮 Starting frontend..."
cd ~/MonetArcade && npm run dev
