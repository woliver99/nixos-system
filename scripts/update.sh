#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script as root (sudo)"
  exit 1
fi

echo "Updating submodules..."
git submodule update --remote --merge

echo "Launching Update Manager..."
nix-shell -p "python313.withPackages (ps: with ps; [ rich ])" --run "python3 nixos-system/scripts/update_manager.py"
