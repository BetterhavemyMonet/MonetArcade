#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "🧠 Creating SAFE GIT BACKUP..."

cd ~/MonetArcade || exit 1

# Ensure git repo exists
if [ ! -d .git ]; then
  echo "❌ Not a git repo yet. Initializing..."
  git init
fi

# Create timestamp
STAMP=$(date +%Y%m%d-%H%M%S)

# Create backup branch
git checkout -b "backup-$STAMP" 2>/dev/null || git checkout "backup-$STAMP"

# Stage everything
git add .

# Commit safely (avoid empty commit failure)
git commit -m "🔐 backup snapshot $STAMP (arcade engine state)" || echo "Nothing to commit"

# Switch back to main branch
git checkout main 2>/dev/null || git checkout -b main

# Merge backup into main safely
git merge "backup-$STAMP" --no-edit || true

# Tag build
git tag -a "snapshot-$STAMP" -m "Arcade snapshot $STAMP" || true

echo "🚀 Pushing to remote..."

# Ensure remote exists
if git remote | grep -q origin; then
  git push origin main || true
  git push origin --tags || true
else
  echo "⚠️ No remote 'origin' configured — skipping push"
  echo "👉 Add with: git remote add origin <repo-url>"
fi

echo "✅ BACKUP COMPLETE"
echo "📦 Snapshot tag: snapshot-$STAMP"
