#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script as root (sudo)"
  exit 1
fi

echo "🚀 Starting NixOS Pre-Install Bootstrapper..."

REPO_TARBALL_URL="https://github.com/woliver99/nixos-system/archive/refs/heads/master.tar.gz"
TEMP_DIR="/tmp/nixos-installer"

echo "Fetching installer package from repository..."
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
curl -sL "$REPO_TARBALL_URL" | tar -xz -C "$TEMP_DIR" --strip-components=1

echo "Launching Install Manager..."
cd "$TEMP_DIR"
nix-shell "$TEMP_DIR/scripts/installer/shell.nix" --run "python3 -m scripts.installer.main"

# Clean up
rm -rf "$TEMP_DIR"
