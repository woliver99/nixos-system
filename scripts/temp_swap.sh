#!/usr/bin/env bash
# Meant for when inside nixos minimal installation
# Can be ran with: curl -sL https://raw.githubusercontent.com/woliver99/nixos-system/refs/heads/master/scripts/temp_swap.sh -o /tmp/temp_swap.sh && sudo bash /tmp/temp_swap.sh && rm /tmp/temp_swap.sh
set -e

if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script as root (sudo)"
  exit 1
fi

dd if=/dev/zero of=/var/swapfile bs=1M count=2048
chmod 600 /var/swapfile
mkswap /var/swapfile
swapon /var/swapfile
swapon --show
