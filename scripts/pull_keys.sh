#!/usr/bin/env bash
# Meant for when inside nixos minimal installation
# Can be pasted in proxmox with: nix-shell -p dotool --run 'sleep 2 && echo "type curl -sL https://raw.githubusercontent.com/woliver99/nixos-system/refs/heads/master/scripts/pull_keys.sh -o /tmp/pull_keys.sh && sudo bash /tmp/pull_keys.sh && rm /tmp/pull_keys.sh" | dotool'
set -e

if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script as root (sudo)"
  exit 1
fi

mkdir -p /root/.ssh && chmod 700 /root/.ssh
curl https://github.com/woliver99.keys >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
