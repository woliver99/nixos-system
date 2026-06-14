#!/usr/bin/env bash
set -e

# --- Root Check ---
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script as root (sudo)"
  exit 1
fi

echo "🚀 Starting NixOS Automated Installer..."

# --- Helper Functions ---
ask_yes_no() {
    while true; do
        read -p "$1 [y/N]: " yn
        case $yn in
            [Yy]* ) return 0;; # Yes
            [Nn]* | "" ) return 1;; # No (Default)
            * ) echo "Please answer yes or no.";;
        esac
    done
}

get_partition_prefix() {
    local disk=$1
    # If the disk ends in a number (like nvme0n1 or mmcblk1), partitions use 'p' (nvme0n1p1)
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
    read -p "Enter the drive to format (e.g., /dev/sda, /dev/mmcblk1): " DISK

    if [ ! -b "$DISK" ]; then
        echo "❌ Drive $DISK not found. Exiting."
        exit 1
    fi

    PART_PREFIX=$(get_partition_prefix "$DISK")

    # --- Filesystem Selection ---
    echo ""
    echo "Select the filesystem for the Root partition:"
    echo "1) ext4 (Standard, highly stable)"
    echo "2) f2fs (Optimized for SD Cards, eMMC, and flash lifespan)"
    while true; do
        read -p "Enter choice [1 or 2]: " FS_CHOICE
        case $FS_CHOICE in
            1) ROOT_FS="ext4"; break;;
            2) ROOT_FS="f2fs"; break;;
            *) echo "Please enter 1 or 2.";;
        esac
    done

    echo ""
    echo "⚠️  WARNING: This will DESTROY ALL DATA on $DISK."
    if ask_yes_no "Are you absolutely sure?"; then
        
        # Unmount anything on that disk just in case
        umount ${PART_PREFIX}* 2>/dev/null || true

        echo "Creating Standard UEFI partitions (GPT, FAT32 Boot + $ROOT_FS Root)..."
        parted $DISK -- mklabel gpt
        parted $DISK -- mkpart ESP fat32 1MiB 1024MiB
        parted $DISK -- set 1 esp on
        # Omitting the fs-type hint here so parted doesn't get confused by f2fs
        parted $DISK -- mkpart primary 1024MiB 100%
        
        echo "Formatting boot partition..."
        mkfs.fat -F 32 -n boot ${PART_PREFIX}1

        echo "Formatting root partition as $ROOT_FS..."
        if [ "$ROOT_FS" == "f2fs" ]; then
            mkfs.f2fs -f -l nixos ${PART_PREFIX}2
        else
            mkfs.ext4 -F -L nixos ${PART_PREFIX}2
        fi

        udevadm settle # Wait for Linux to create the /dev/disk/by-label/ shortcuts
        
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
echo "   (Or copy your existing configuration folder here!)"
echo "2. Once you are done configuring, run:"
echo "   nixos-install"
echo "3. Reboot your system!"
echo "--------------------------------------------------------"
