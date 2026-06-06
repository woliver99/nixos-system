#!/usr/bin/env bash
set -e

# --- Root Check ---
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script as root (sudo su -)"
  exit 1
fi

mkdir -p /etc/nixos/
cd /etc/nixos/
sudo nix-shell -p git --run "sudo git init && sudo git submodule add https://github.com/woliver99/nixos-system.git nixos-system && sudo git submodule update --init --recursive"
