import os
import subprocess
from .utils import run_cmd, console
from .ui import InstallConfig


def cleanup_previous_mounts(part_prefix: str) -> None:
    """Unmounts existing mountpoints and closes mapper devices cleanly."""
    run_cmd("umount -R /mnt 2>/dev/null || true", shell=True, check=False)
    run_cmd(f"umount -R {part_prefix}* 2>/dev/null || true", shell=True, check=False)
    run_cmd("cryptsetup close enc-pv 2>/dev/null || true", shell=True, check=False)


def setup_uefi_partitions(disk: str, part_prefix: str) -> None:
    """Creates a GPT partition table with 1GB ESP and root partition."""
    run_cmd("parted", "-s", disk, "--", "mklabel", "gpt")
    run_cmd("parted", "-s", disk, "--", "mkpart", "ESP", "fat32", "1MiB", "1024MiB")
    run_cmd("parted", "-s", disk, "--", "set", "1", "esp", "on")
    run_cmd("parted", "-s", disk, "--", "mkpart", "primary", "1024MiB", "100%")
    run_cmd("mkfs.fat", "-F", "32", "-n", "boot", f"{part_prefix}1")
    run_cmd("udevadm", "settle")


def setup_btrfs(cfg: InstallConfig) -> None:
    """Handles LUKS2 encryption, Btrfs subvolumes, and mounting (ephemeral or standard)."""
    target_dev = f"{cfg.part_prefix}2"

    if cfg.use_luks:
        console.print(
            "\n[bold yellow]🔐 Setting up LUKS2 encryption. Enter your disk passphrase:[/bold yellow]"
        )
        # Wipe leftover partition headers so cryptsetup never asks to confirm overwriting
        run_cmd("wipefs", "-af", f"{cfg.part_prefix}2")

        subprocess.run(
            [
                "cryptsetup",
                "luksFormat",
                "-q",
                "--type",
                "luks2",
                f"{cfg.part_prefix}2",
            ],
            check=True,
        )
        subprocess.run(
            ["cryptsetup", "open", f"{cfg.part_prefix}2", "enc-pv"],
            check=True,
        )
        target_dev = "/dev/mapper/enc-pv"

    run_cmd("mkfs.btrfs", "-f", "-L", "nixos", target_dev)
    run_cmd("mount", target_dev, "/mnt")
    run_cmd("btrfs", "subvolume", "create", "/mnt/@nix")
    run_cmd("btrfs", "subvolume", "create", "/mnt/@home")

    if cfg.use_impermanence:
        run_cmd("btrfs", "subvolume", "create", "/mnt/@persist")
        run_cmd("umount", "/mnt")

        run_cmd("mount", "-t", "tmpfs", "none", "/mnt", "-o", "size=4G,mode=755")
        os.makedirs("/mnt/persist", exist_ok=True)
        run_cmd(
            "mount",
            "-o",
            "subvol=@persist,compress=zstd,autodefrag",
            target_dev,
            "/mnt/persist",
        )

        os.makedirs("/mnt/persist/etc/nixos", exist_ok=True)
        os.makedirs("/mnt/etc/nixos", exist_ok=True)
        run_cmd("mount", "--bind", "/mnt/persist/etc/nixos", "/mnt/etc/nixos")
    else:
        run_cmd("btrfs", "subvolume", "create", "/mnt/@root")
        run_cmd("umount", "/mnt")
        run_cmd("mount", "-o", "subvol=@root,compress=zstd,noatime", target_dev, "/mnt")

    # Shared mounts
    os.makedirs("/mnt/home", exist_ok=True)
    run_cmd("mount", "-o", "subvol=@home,compress=zstd", target_dev, "/mnt/home")

    os.makedirs("/mnt/nix", exist_ok=True)
    run_cmd("mount", "-o", "subvol=@nix,compress=zstd,noatime", target_dev, "/mnt/nix")

    os.makedirs("/mnt/boot", exist_ok=True)
    run_cmd("mount", "/dev/disk/by-label/boot", "/mnt/boot")


def setup_standard_fs(cfg: InstallConfig) -> None:
    """Formats and mounts ext4 or f2fs partitions."""
    run_cmd(
        f"mkfs.{cfg.fs_choice}",
        "-f" if cfg.fs_choice == "f2fs" else "-F",
        "-L" if cfg.fs_choice == "ext4" else "-l",
        "nixos",
        f"{cfg.part_prefix}2" if cfg.boot_mode == "uefi" else f"{cfg.part_prefix}1",
    )
    run_cmd("udevadm", "settle")
    run_cmd("mount", "/dev/disk/by-label/nixos", "/mnt")
    if cfg.boot_mode == "uefi":
        os.makedirs("/mnt/boot", exist_ok=True)
        run_cmd("mount", "/dev/disk/by-label/boot", "/mnt/boot")


def setup_bios_partitions(disk: str) -> None:
    """Creates an MBR partition table for legacy boot."""
    run_cmd("parted", "-s", disk, "--", "mklabel", "msdos")
    run_cmd("parted", "-s", disk, "--", "mkpart", "primary", "ext4", "1MiB", "100%")
