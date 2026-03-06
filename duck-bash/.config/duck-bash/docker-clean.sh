#!/usr/bin/env bash
set -euo pipefail

if ! command -v docker &>/dev/null; then
  echo "Error: docker is not installed."
  exit 1
fi

echo "Cleaning up Docker containers, networks, volumes, and build cache..."
echo "Images will NOT be deleted."

# Stop all running containers
running=$(docker ps -q)
if [[ -n "$running" ]]; then
  echo "Stopping all running containers..."
  docker stop $running
fi

# Remove all containers (stopped + exited)
all=$(docker ps -aq)
if [[ -n "$all" ]]; then
  echo "Removing all containers..."
  docker rm -f $all
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

