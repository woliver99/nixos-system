#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script as root (sudo)"
  exit 1
fi

DRY_RUN=0
if [ "$1" == "--dry-run" ]; then
  DRY_RUN=1
fi

if [ "$DRY_RUN" -eq 0 ]; then
  echo "Updating main system submodule from remote..."
  git submodule update --init --remote --merge nixos-system

  echo "Syncing nested submodules to pinned commits..."
  git -C nixos-system submodule update --init --recursive
else
  echo "Dry-run mode: Skipping remote repository and submodule updates."
  export MIGRATION_DRY_RUN=1
fi

echo "Launching Update Manager..."
nix-shell -p "python313.withPackages (ps: with ps; [ rich ])" --run "python3 nixos-system/scripts/update_manager.py"
