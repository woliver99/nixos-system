#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p "python313.withPackages(ps: with ps; [ rich ])"

import os
import sys
import subprocess
import time
from rich.console import Console
from rich.prompt import Prompt
from rich.table import Table

console = Console()

# URL to pull your live script
SCRIPT_URL = "https://raw.githubusercontent.com/woliver99/nixos-system/refs/heads/master/scripts/install_manager.py"
TARGET_SCRIPT = "/tmp/install_manager_test.py"

def run_cmd(cmd, shell=False, input_data=None):
    """Runs a command, optionally passing string inputs to stdin."""
    res = subprocess.run(
        cmd,
        shell=shell,
        input=input_data,
        text=True,
        capture_output=True
    )
    return res

def check_mounts(disk, boot_mode, expected_fs):
    """
    Strictly verifies:
    1. The partition table layout (gpt for UEFI, dos for BIOS)
    2. That the paths are mounted
    3. That the root filesystem is exactly what we requested (ext4 vs f2fs)
    """
    # 1. Verify Partition Table Type via blkid
    # (returns 'gpt' for UEFI, 'dos' for Legacy BIOS)
    pt_res = subprocess.run(
        ["blkid", "-o", "value", "-s", "PTTYPE", disk],
        text=True, capture_output=True
    )
    actual_pt = pt_res.stdout.strip()
    expected_pt = "gpt" if boot_mode == "uefi" else "dos"
    
    if actual_pt != expected_pt:
        return False, f"Wrong Partition Table: Expected {expected_pt}, got {actual_pt}"

    # 2. Verify Mounts and Filesystem Types
    nixos_mounted = False
    boot_mounted = True if boot_mode == "bios" else False
    
    with open("/proc/mounts", "r") as f:
        for line in f:
            parts = line.split()
            if len(parts) < 3:
                continue
            
            mount_point = parts[1]
            fs_type = parts[2]
            
            # Check root partition mount and format type
            if mount_point == "/mnt":
                if fs_type == expected_fs:
                    nixos_mounted = True
                else:
                    return False, f"Wrong Root FS: Expected {expected_fs}, got {fs_type}"
            
            # Check UEFI boot partition mount (vfat)
            if boot_mode == "uefi" and mount_point == "/mnt/boot":
                if fs_type in ["vfat", "msdos"]:
                    boot_mounted = True

    if nixos_mounted and boot_mounted:
        return True, "PASSED"
    else:
        return False, "Missing Expected Mount Points"

def clean_disk(disk):
    """Force unmounts everything to prepare for the next test iteration."""
    disk_name = disk.replace("/dev/", "")
    subprocess.run(f"umount -R /mnt 2>/dev/null || true", shell=True)
    subprocess.run(f"umount -R /dev/{disk_name}* 2>/dev/null || true", shell=True)

def main():
    if os.geteuid() != 0:
        console.print("[bold red]❌ Run as root (sudo).[/bold red]")
        sys.exit(1)

    # Get the target drive to abuse during the test
    subprocess.run("lsblk -dpno NAME,SIZE,MODEL", shell=True)
    disk = Prompt.ask("\nEnter the drive path to run automation tests on")
    
    if not os.path.exists(disk):
        console.print(f"[bold red]❌ Disk {disk} not found.[/bold red]")
        sys.exit(1)

    # Fetch your exact live install manager script
    console.print(f"[cyan]Downloading live install_manager.py...[/cyan]")
    run_cmd(["curl", "-sL", SCRIPT_URL, "-o", TARGET_SCRIPT])

    # Test matrix combinations
    matrix = [
        {"boot": "uefi", "fs": "ext4"},
        {"boot": "uefi", "fs": "f2fs"},
        {"boot": "bios", "fs": "ext4"},
        {"boot": "bios", "fs": "f2fs"},
    ]

    results = Table(title="Automation Test Results for install_manager.py", show_header=True, header_style="bold magenta")
    results.add_column("Boot Mode", style="cyan")
    results.add_column("Filesystem", style="magenta")
    results.add_column("Script Execution", style="yellow")
    results.add_column("Mount Verification", style="green")

    for run in matrix:
        boot = run["boot"]
        fs = run["fs"]
        
        console.print(f"\n[bold blue]🤖 Automating: {boot.upper()} + {fs.upper()}[/bold blue]")
        clean_disk(disk)

        simulated_inputs = f"y\n{disk}\n{boot}\n{fs}\ny\ny\n"
        proc = run_cmd(["python3", TARGET_SCRIPT], input_data=simulated_inputs)
        
        exec_status = "[green]SUCCESS[/green]" if proc.returncode == 0 else "[red]FAILED[/red]"
        
        # Verify hardware states using the updated rigorous function
        subprocess.run(["udevadm", "settle"])
        time.sleep(1) # Give the kernel a breath to populate /proc/mounts
        
        is_valid, message = check_mounts(disk, boot, fs)
        
        if is_valid:
            mount_status = "[green]PASSED[/green]"
        else:
            mount_status = f"[red]FAILED ({message})[/red]"

        results.add_row(boot.upper(), fs.upper(), exec_status, mount_status)
        
        if proc.returncode != 0:
            console.print(f"[bold red]Error Output from script:[/bold red]\n{proc.stderr}")

    # Final sweep
    clean_disk(disk)
    if os.path.exists(TARGET_SCRIPT):
        os.remove(TARGET_SCRIPT)

    console.print("\n")
    console.print(results)

if __name__ == "__main__":
    main()
