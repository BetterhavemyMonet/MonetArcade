#!/bin/bash

echo "🚀 Monet Arcade Full Boot Starting..."

# -------------------------
# FRONTEND SETUP
# -------------------------
cd ~/MonetArcade || exit

if [ ! -d node_modules ]; then
  echo "📦 Installing frontend dependencies..."
  npm install
fi

mkdir -p src/pay

# -------------------------
# BACKEND SETUP
# -------------------------
cd ~/monet-backend || exit

if [ ! -f server.js ]; then
  echo "⚠️ server.js missing — creating minimal backend..."

  cat > server.js << 'INNER'
const express = require("express");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

app.get("/api/games", (req, res) => {
  res.json([
    { id: "monet-mario", title: "Monet Mario", price: 100 },
    { id: "monet-racer", title: "Monet Racer", price: 100 },
    { id: "monet-tetris", title: "Monet Tetris", price: 100 },
    { id: "monet-frog", title: "Token Frog", price: 100 }
  ]);
});

app.post("/api/play", (req, res) => {
  const { wallet, gameId } = req.body;
  if (!wallet || !gameId) {
    return res.status(400).json({ error: "Missing data" });
  }

  return res.json({
    success: true,
    sessionId: gameId + "-" + Date.now()
  });
});

app.listen(5000, () => {
  console.log("🚀 Backend running on http://localhost:5000");
});
INNER
fi

if [ ! -d node_modules ]; then
  echo "📦 Installing backend dependencies..."
  npm install express cors
fi

# -------------------------
# START BACKEND
# -------------------------
echo "🔧 Starting backend..."
node server.js &
BACKEND_PID=$!

sleep 2

# -------------------------
# START FRONTEND
# -------------------------
cd ~/MonetArcade || exit
echo "🎮 Starting frontend..."
npm run dev &
FRONTEND_PID=$!

sleep 3

# -------------------------
# VERIFY
# -------------------------
echo "🔍 Checking API..."
curl -s http://localhost:5000/api/games

echo ""
echo "✅ Monet Arcade is LIVE"
echo "Backend PID: $BACKEND_PID"
echo "Frontend PID: $FRONTEND_PID"
