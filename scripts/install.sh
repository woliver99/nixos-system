#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script as root (sudo)"
  exit 1
fi

echo "🚀 Starting NixOS Pre-Install Bootstrapper..."

PYTHON_SCRIPT_URL="https://raw.githubusercontent.com/woliver99/nixos-system/refs/heads/master/scripts/install_manager.py"
PYTHON_SCRIPT_DEST="/tmp/install_manager.py"

echo "Fetching Install Manager from repository..."
curl -sL "$PYTHON_SCRIPT_URL" -o "$PYTHON_SCRIPT_DEST"

echo "Launching Install Manager..."
nix-shell -p "python313.withPackages (ps: with ps; [ rich ])" --run "python3 $PYTHON_SCRIPT_DEST"

# Clean up
rm -f "$PYTHON_SCRIPT_DEST"
