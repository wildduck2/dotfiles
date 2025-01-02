#!/bin/bash

# Check if URL is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <youtube-video-url>"
  exit 1
fi

# The YouTube URL
VIDEO_URL="$1"

# Ask the user for preferred resolution
echo "Choose the desired resolution:"
echo "1. 1080p"
echo "2. 720p"
echo "3. Best Available"

read -p "Enter your choice (1/2/3): " RESOLUTION

# Determine the format selection based on the resolution
case "$RESOLUTION" in
  1)
    FORMAT="bestvideo[height=1080]+bestaudio/best[height=1080]"
    ;;
  2)
    FORMAT="bestvideo[height=720]+bestaudio/best[height=720]"
    ;;
  3)
    FORMAT="best"
    ;;
  *)
    echo "Invalid choice. Downloading the best available quality."
    FORMAT="best"
    ;;
esac

# Run yt-dlp to download the video in the selected resolution
yt-dlp -f "$FORMAT" "$VIDEO_URL"

echo "Download complete."

