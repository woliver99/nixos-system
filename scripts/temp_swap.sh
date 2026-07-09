#!/usr/bin/env bash
# Meant for when inside nixos minimal installation to prevent OOM during builds
# Can be run with: curl -sL https://raw.githubusercontent.com/woliver99/nixos-system/refs/heads/master/scripts/temp_swap.sh -o /tmp/temp_swap.sh && sudo bash /tmp/temp_swap.sh && rm /tmp/temp_swap.sh
set -e

if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script as root (sudo)"
  exit 1
fi

echo "🌀 Calculating 150% of total physical RAM..."
# Extract MemTotal from /proc/meminfo (given in kB) and convert to bytes
MEM_TOTAL_KB=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
ZRAM_SIZE_BYTES=$(( MEM_TOTAL_KB * 1024 * 3 / 2 ))
ZRAM_SIZE_MB=$(( ZRAM_SIZE_BYTES / 1024 / 1024 ))

echo "📦 Ensuring zram kernel module is loaded..."
if [ ! -b /dev/zram0 ]; then
  modprobe zram num_devices=1
fi

# If the installer environment already activated zram0, turn it off to allow resizing
if swapon --show | grep -q '/dev/zram0'; then
  echo "🔄 Deactivating existing zram0 swap..."
  swapoff /dev/zram0
fi

echo "⏳ Waiting for system storage layers to settle..."
udevadm settle || true
sleep 1

echo "🧹 Resetting zram0 device disksize..."
# The device must be reset to 1 before its maximum disksize can be changed
echo 1 > /sys/block/zram0/reset

echo "⚙️ Setting zram0 virtual size to 150% of RAM (${ZRAM_SIZE_MB} MB)..."
echo "$ZRAM_SIZE_BYTES" > /sys/block/zram0/disksize

echo "🛠️ Formatting zram0 as swap..."
mkswap /dev/zram0

echo "🚀 Activating zram0 swap with maximum priority..."
# Priority 32767 ensures the system hits this compressed RAM before any other swap
swapon -p 32767 /dev/zram0

echo -e "\n✅ Success! Modern compressed memory airbag is active:"
swapon --show
