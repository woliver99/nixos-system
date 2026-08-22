#!/usr/bin/env bash
# curl -sL https://raw.githubusercontent.com/woliver99/nixos-system/refs/heads/master/scripts/tests/test_install.sh | sudo bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this test runner as root (sudo)"
  exit 1
fi

echo "🚀 Setting up NixOS Installation Test Environment..."

REPO_TARBALL_URL="https://github.com/woliver99/nixos-system/archive/refs/heads/master.tar.gz"
TEMP_DIR="/tmp/nixos-installer-test"

# Clean up any leftover test directories
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

echo "📦 Fetching repository files..."
curl -sL "$REPO_TARBALL_URL" | tar -xz -C "$TEMP_DIR" --strip-components=1

echo "🔧 Launching test runner inside Nix environment..."
cd "$TEMP_DIR"
nix-shell -p \
  "python313.withPackages (ps: with ps; [ rich ])" \
  parted \
  cryptsetup \
  btrfs-progs \
  e2fsprogs \
  f2fs-tools \
  dosfstools \
  util-linux \
  --run "python3 scripts/tests/test_installer.py"

# Clean up repository files after test completion
rm -rf "$TEMP_DIR"
