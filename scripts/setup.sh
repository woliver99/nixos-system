#!/usr/bin/env bash
set -e

# --- Root Check ---
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script as root (sudo)"
  exit 1
fi

nix-shell -p git --run "git init && git submodule add https://github.com/woliver99/nixos-system.git nixos-system && git submodule update --init --recursive"

bash ./nixos-system/scripts/update.sh
