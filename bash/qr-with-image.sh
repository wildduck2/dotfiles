#!/bin/bash

# Exit on error
set -e

# Check dependencies
if ! command -v qrencode &> /dev/null; then
    echo "Error: qrencode is not installed. Please install it first."
    exit 1
fi

if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick is not installed. Please install it first."
    exit 1
fi

# Usage function
usage() {
    echo "Usage: $0 -t 'text_or_url' -i 'image_path' -o 'output_path'"
    echo "Options:"
    echo "  -t TEXT    The text or URL to encode in the QR code."
    echo "  -i IMAGE   Path to the image to embed in the QR code."
    echo "  -o OUTPUT  Path to save the generated QR code. Default is './qr-code.png'."
    exit 1
}

# Parse arguments
while getopts ":t:i:o:" opt; do
    case $opt in
        t) TEXT="$OPTARG" ;;
        i) IMAGE="$OPTARG" ;;
        o) OUTPUT="$OPTARG" ;;
        *) usage ;;
    esac
done

# Validate input
if [[ -z "$TEXT" || -z "$IMAGE" ]]; then
    echo "Error: Missing required arguments."
    usage
fi

# Default output file
OUTPUT=${OUTPUT:-./qr-code.png}

# Temporary files
TEMP_QR="./temp-qr.png"
TEMP_RESIZED="./temp-resized.png"

# Generate a larger QR code (increase the -s scale value to make the QR code bigger)
qrencode -o "$TEMP_QR" -s 60 -m 4 "$TEXT"

# Resize the input image to fit the QR code center (20% of QR code size)
QR_SIZE=$(identify -format "%w" "$TEMP_QR")
RESIZE_SIZE=$((QR_SIZE / 7))
convert "$IMAGE" -resize "${RESIZE_SIZE}x${RESIZE_SIZE}" "$TEMP_RESIZED"

# Overlay the resized image on the QR code
convert "$TEMP_QR" "$TEMP_RESIZED" -gravity center -composite "$OUTPUT"

# Clean up temporary files
rm -f "$TEMP_QR" "$TEMP_RESIZED"

echo "QR code generated and saved to: $OUTPUT"

