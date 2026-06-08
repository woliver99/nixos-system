#!/usr/bin/env bash
set -e

# --- Root Check ---
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script as root (sudo su -)"
  exit 1
fi

echo "🚀 Starting NixOS Automated Installer..."

# --- Helper Functions ---
# Note: '< /dev/tty' forces the read command to wait for keyboard input, 
# preventing 'curl | bash' from breaking the prompts.
ask_yes_no() {
    while true; do
        read -p "$1 [y/N]: " yn < /dev/tty
        case $yn in
            [Yy]* ) return 0;; # Yes
            [Nn]* | "" ) return 1;; # No (Default)
            * ) echo "Please answer yes or no.";;
        esac
    done
}

get_partition_prefix() {
    local disk=$1
    # If the disk ends in a number (like nvme0n1), partitions use 'p' (nvme0n1p1)
    if [[ $disk =~ [0-9]$ ]]; then
        echo "${disk}p"
    else
        echo "${disk}"
    fi
}

# --- Partitioning ---
if ask_yes_no "Do you want to setup partitions on a drive? (Standard UEFI)"; then
    echo ""
    echo "Available drives:"
    lsblk -dpno NAME,SIZE,MODEL
    echo ""
    read -p "Enter the drive to format (e.g., /dev/sda, /dev/nvme0n1): " DISK < /dev/tty

    if [ ! -b "$DISK" ]; then
        echo "❌ Drive $DISK not found. Exiting."
        exit 1
    fi

    PART_PREFIX=$(get_partition_prefix "$DISK")

    echo "⚠️  WARNING: This will DESTROY ALL DATA on $DISK."
    if ask_yes_no "Are you absolutely sure?"; then
        
        # Unmount anything on that disk just in case
        umount ${PART_PREFIX}* 2>/dev/null || true

        echo "Creating Standard UEFI partitions (GPT, FAT32 Boot + Ext4 Root)..."
        parted $DISK -- mklabel gpt
        parted $DISK -- mkpart ESP fat32 1MiB 1024MiB
        parted $DISK -- set 1 esp on
        parted $DISK -- mkpart primary ext4 1024MiB 100%
        
        echo "Formatting..."
        mkfs.fat -F 32 -n boot ${PART_PREFIX}1
        mkfs.ext4 -L nixos ${PART_PREFIX}2
        
        echo "Mounting..."
        mount /dev/disk/by-label/nixos /mnt
        mkdir -p /mnt/boot
        mount /dev/disk/by-label/boot /mnt/boot
        
        echo "✅ Partitions created and mounted."
    else
        echo "Partitioning aborted."
    fi
else
    echo "Skipping partitioning. (Assuming drives are already mounted to /mnt)"
fi

echo ""

# --- NixOS Configuration ---
if ask_yes_no "Do you want to run nixos-generate-config?"; then
    echo "Generating NixOS configuration..."
    nixos-generate-config --root /mnt
    echo "✅ Configuration generated at /mnt/etc/nixos/"
fi

# --- Final Instructions ---
echo ""
echo "--------------------------------------------------------"
echo "🎉 Setup phase complete!"
echo ""
echo "Next steps:"
echo "1. Configure your system and bootloader by editing:"
echo "   nano /mnt/etc/nixos/configuration.nix"
echo "2. Once you are done configuring, run:"
echo "   nixos-install"
echo "3. Reboot your system!"
echo "--------------------------------------------------------"
