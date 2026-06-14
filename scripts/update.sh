#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script as root (sudo)"
  exit 1
fi

echo "Updating main system submodule from remote..."
git submodule update --init --remote --merge

echo "Syncing nested submodules to pinned commits..."
git submodule update --init --recursive

echo "Launching Update Manager..."
nix-shell -p "python313.withPackages (ps: with ps; [ rich ])" --run "python3 nixos-system/scripts/update_manager.py"
