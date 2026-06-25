#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "🚀 MonetArcade Sync + Deploy Starting..."

# CONFIG
DOMAIN="betterhavemymonet.com"
PROJECT_DIR="$HOME/MonetArcade"

# Cloudflare
CF_ZONE_ID="YOUR_CLOUDFLARE_ZONE_ID"
CF_TOKEN="YOUR_CLOUDFLARE_API_TOKEN"

# Vercel
VERCEL_PROJECT="monet-arcade"

cd "$PROJECT_DIR"

echo "📥 Pulling latest Git changes..."
git fetch origin
git pull origin main

echo "📦 Installing dependencies..."
npm install

echo "🧹 Cleaning old build..."
rm -rf dist

echo "🏗️ Building project..."
npm run build

echo "☁️ Deploying to Vercel..."
vercel --prod --yes

echo "🌐 Updating Cloudflare DNS..."

# Get current Vercel domain target
VERCEL_TARGET="cname.vercel-dns.com"

# Find existing CNAME
DNS_ID=$(curl -s \
-X GET \
"https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records?type=CNAME&name=$DOMAIN" \
-H "Authorization: Bearer $CF_TOKEN" \
-H "Content-Type: application/json" \
| grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$DNS_ID" ]; then

echo "➕ Creating CNAME..."

curl -s \
-X POST \
"https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records" \
-H "Authorization: Bearer $CF_TOKEN" \
-H "Content-Type: application/json" \
--data "{
\"type\":\"CNAME\",
\"name\":\"@\",
\"content\":\"$VERCEL_TARGET\",
\"ttl\":1,
\"proxied\":false
}"

else

echo "🔄 Updating existing DNS..."

curl -s \
-X PUT \
"https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records/$DNS_ID" \
-H "Authorization: Bearer $CF_TOKEN" \
-H "Content-Type: application/json" \
--data "{
\"type\":\"CNAME\",
\"name\":\"@\",
\"content\":\"$VERCEL_TARGET\",
\"ttl\":1,
\"proxied\":false
}"

fi


echo "🧹 Clearing Cloudflare cache..."

curl -s \
-X POST \
"https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/purge_cache" \
-H "Authorization: Bearer $CF_TOKEN" \
-H "Content-Type: application/json" \
--data '{"purge_everything":true}'


echo "🔍 Checking site..."

curl -I "https://betterhavemymonet.comN" | head


echo ""
echo "✅ MonetArcade deployed successfully!"
echo "🌎 https://$DOMAIN"
