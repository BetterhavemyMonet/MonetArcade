#!/bin/bash

set -Eeuo pipefail

APP_NAME="MonetArcade"
BRANCH="main"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
RELEASE_DIR="releases/$TIMESTAMP"
CURRENT_LINK="current"
LOG_DIR="logs"

mkdir -p "$LOG_DIR"
mkdir -p releases

exec > >(tee -a "$LOG_DIR/deploy-$TIMESTAMP.log")
exec 2>&1

echo "======================================"
echo "Monet Arcade Enterprise Deployment"
echo "Release: $TIMESTAMP"
echo "======================================"

# Verify git state
git fetch origin

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/$BRANCH)

if [ "$LOCAL" != "$REMOTE" ]; then
    echo "Syncing with origin/$BRANCH..."
    git pull origin $BRANCH
fi

# Dependency verification
echo "Verifying package lock..."

if [ ! -f package-lock.json ]; then
    echo "ERROR: package-lock.json missing"
    exit 1
fi

# Clean install using lockfile
npm ci --legacy-peer-deps

# Run tests if present
if npm run | grep -q test; then
    npm test || exit 1
fi

# Build
npm run build

if [ ! -d dist ]; then
    echo "Build failed"
    exit 1
fi

# Create release
mkdir -p "$RELEASE_DIR"
cp -r dist "$RELEASE_DIR/"
cp package.json "$RELEASE_DIR/"

# Keep rollback pointer
PREVIOUS=""
if [ -L "$CURRENT_LINK" ]; then
    PREVIOUS=$(readlink "$CURRENT_LINK")
fi

ln -sfn "$RELEASE_DIR" "$CURRENT_LINK"

echo "Release activated: $RELEASE_DIR"

# Deploy to Vercel if available
if command -v vercel >/dev/null 2>&1; then
    vercel --prod --yes
fi

# Health check
URL="https://betterhavemymonet.com"

echo "Waiting for deployment..."

sleep 15

STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL")

if [ "$STATUS" != "200" ]; then
    echo "Health check failed ($STATUS)"

    if [ -n "$PREVIOUS" ]; then
        echo "Rolling back..."
        ln -sfn "$PREVIOUS" "$CURRENT_LINK"
    fi

    exit 1
fi

echo "Deployment successful."
echo "HTTP $STATUS"

# Cleanup old releases (keep last 5)
ls -dt releases/* | tail -n +6 | xargs rm -rf 2>/dev/null || true

echo "Done."
