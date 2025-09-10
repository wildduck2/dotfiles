#!/usr/bin/env bash
set -euo pipefail

echo "🔄 Cleaning up Docker containers, networks, volumes, and build cache..."
echo "⚠️ Images will NOT be deleted."

# Stop all running containers
if [ "$(docker ps -q)" ]; then
  echo "🛑 Stopping all running containers..."
  docker stop $(docker ps -q)
fi

# Remove all containers (stopped + exited)
if [ "$(docker ps -aq)" ]; then
  echo "🗑 Removing all containers..."
  docker rm -f $(docker ps -aq)
fi

# Remove all unused networks
echo "🛠 Removing unused networks..."
docker network prune -f

# Remove all unused volumes
echo "🗄 Removing unused volumes..."
docker volume prune -f

# Remove build cache (but keep images)
echo "🧹 Removing build cache..."
docker builder prune -f

echo "✅ Docker cleanup complete! All images are still available."

