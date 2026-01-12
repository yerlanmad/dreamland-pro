#!/bin/bash
set -e

echo "🚀 Manual Deployment Script for Dreamland PRO"
echo "=============================================="

# Get RAILS_MASTER_KEY from local file
RAILS_MASTER_KEY=$(cat config/master.key)

# Build and push image
echo "📦 Building and pushing Docker image..."
kamal build push

# Deploy on server
echo "🚢 Deploying container on server..."
ssh root@46.62.241.204 bash -s <<EOF
set -e

echo "Pulling latest image..."
docker pull erlanmad/dreamland_pro:latest

echo "Stopping existing container..."
docker stop dreamland_pro-web 2>/dev/null || true
docker rm dreamland_pro-web 2>/dev/null || true

echo "Creating volume..."
docker volume create dreamland_pro_storage 2>/dev/null || true

echo "Starting new container..."
docker run -d \\
  --name dreamland_pro-web \\
  --restart unless-stopped \\
  -v dreamland_pro_storage:/rails/storage \\
  -e RAILS_MASTER_KEY="${RAILS_MASTER_KEY}" \\
  -e SOLID_QUEUE_IN_PUMA=true \\
  -e RAILS_ASSUME_SSL=true \\
  -e RAILS_FORCE_SSL=true \\
  -e RAILS_ENV=production \\
  --network n8n-docker-caddy_default \\
  erlanmad/dreamland_pro:latest

echo "Waiting for container to start..."
sleep 5

echo "Running database migrations..."
docker exec dreamland_pro-web bin/rails db:prepare

echo "Container status:"
docker ps | grep dreamland_pro-web

echo "Recent logs:"
docker logs dreamland_pro-web --tail 20
EOF

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🔍 Test the deployment:"
echo "  curl https://pro.dreamland.kz/up"
echo ""
echo "📊 View logs:"
echo "  ssh root@46.62.241.204 'docker logs dreamland_pro-web -f'"
echo ""
echo "🎮 Rails console:"
echo "  ssh root@46.62.241.204 'docker exec -it dreamland_pro-web bin/rails console'"
