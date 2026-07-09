#!/usr/bin/env bash
# Meant for when inside nixos minimal installation to prevent OOM during builds
# Can be run with: curl -sL https://raw.githubusercontent.com/woliver99/nixos-system/refs/heads/master/scripts/temp_swap.sh -o /tmp/temp_swap.sh && sudo bash /tmp/temp_swap.sh && rm /tmp/temp_swap.sh
set -e

if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script as root (sudo)"
  exit 1
fi

# 1. Ask the user where to put the swap file
echo "📂 Where should the swap file be created?"
echo "👉 (If you are installing NixOS right now, use /mnt/swapfile)"
read -p "Path [/mnt/swapfile]: " SWAP_PATH
SWAP_PATH=${SWAP_PATH:-/mnt/swapfile}

# Validate that the parent directory actually exists
SWAP_DIR=$(dirname "$SWAP_PATH")
if [ ! -d "$SWAP_DIR" ]; then
  echo "❌ Error: The directory '$SWAP_DIR' does not exist."
  echo "   Make sure your target installation disk is mounted to /mnt first!"
  exit 1
fi

# 2. Ask the user for the size of the swap file
echo -e "\n💾 How large should the swap file be (in MB)?"
echo "👉 (4096 MB = 4GB, highly recommended to clear NixOS install builds)"
read -p "Size [4096]: " SWAP_SIZE
SWAP_SIZE=${SWAP_SIZE:-4096}

echo -e "\n🚀 Allocating ${SWAP_SIZE}MB swap file at ${SWAP_PATH}..."
dd if=/dev/zero of="$SWAP_PATH" bs=1M count="$SWAP_SIZE" status=progress

echo "🔒 Setting secure permissions (chmod 600)..."
chmod 600 "$SWAP_PATH"

echo "🛠️ Formatting file as swap..."
mkswap "$SWAP_PATH"

echo "🏁 Activating swap..."
swapon "$SWAP_PATH"

echo -e "\n✅ Success! Current active swap configuration:"
swapon --show
