#!/usr/bin/env bash
set -e

# --- Root Check ---
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script as root (sudo su -)"
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
    # If the disk ends in a number (like nvme0n1 or mmcblk0), partitions use 'p' (nvme0n1p1)
    if [[ $disk =~ [0-9]$ ]]; then
        echo "${disk}p"
    else
        echo "${disk}"
    fi
}

# --- Partitioning ---
if ask_yes_no "Do you want to setup partitions on a drive?"; then
    echo "Available drives:"
    lsblk -dpno NAME,SIZE,MODEL
    read -p "Enter the drive to format (e.g., /dev/sda, /dev/nvme0n1): " DISK

    if [ ! -b "$DISK" ]; then
        echo "❌ Drive $DISK not found. Exiting."
        exit 1
    fi

    PART_PREFIX=$(get_partition_prefix "$DISK")

    echo "Select partition setup:"
    echo "1) Standard UEFI (GPT, FAT32 Boot + Ext4 Root)"
    # [FUTURE EXPANSION]: Add new menu options here (e.g., "2) Legacy BIOS", "3) ZFS Root")
    read -p "Choice (1): " SETUP_TYPE

    echo "⚠️  WARNING: This will DESTROY ALL DATA on $DISK."
    if ask_yes_no "Are you absolutely sure?"; then
        
        # Unmount anything on that disk just in case
        umount ${PART_PREFIX}* 2>/dev/null || true

        case $SETUP_TYPE in
            1)
                echo "Creating Standard UEFI partitions..."
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
                ;;
            # [FUTURE EXPANSION]: Add new case blocks here (e.g., 2) for BIOS, 3) for ZFS)
            *)
                echo "❌ Invalid choice. Exiting."
                exit 1
                ;;
        esac
        echo "✅ Partitions created and mounted."
    else
        echo "Partitioning aborted."
    fi
else
    echo "Skipping partitioning. (Assuming drives are already mounted to /mnt)"
fi

# --- Swapfile Setup ---
if ask_yes_no "Do you want to create a swapfile?"; then
    read -p "Enter swapfile size (e.g., 4G, 8192M): " SWAP_SIZE
    
    echo "Creating swapfile at /mnt/swapfile..."
    fallocate -l $SWAP_SIZE /mnt/swapfile
    chmod 600 /mnt/swapfile
    mkswap /mnt/swapfile
    swapon /mnt/swapfile
    echo "✅ Swapfile created and activated."
fi

# --- NixOS Configuration ---
if ask_yes_no "Do you want to run nixos-generate-config?"; then
    echo "Generating NixOS configuration..."
    nixos-generate-config --root /mnt
    echo "✅ Configuration generated at /mnt/etc/nixos/"
fi

# --- 5. Final Instructions ---
echo "--------------------------------------------------------"
echo "🎉 Setup phase complete!"
echo ""
echo "Next steps:"
echo "1. Configure your system and bootloader (BIOS or UEFI) by editing:"
echo "   nano /mnt/etc/nixos/configuration.nix"
echo "2. Once you are done configuring, run:"
echo "   nixos-install"
echo "3. Reboot your system!"
echo "--------------------------------------------------------"
