import os
import sys
import subprocess
from rich.console import Console
from rich.prompt import Prompt, Confirm
from rich.panel import Panel
from rich.table import Table

console = Console()

def run_cmd(*cmd, shell=False, check=True, capture=False):
    """Executes a system command and handles errors cleanly."""
    try:
        result = subprocess.run(
            cmd if not shell else cmd[0], 
            shell=shell, 
            check=check, 
            text=True, 
            capture_output=capture
        )
        return result.stdout.strip() if capture else True
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]❌ Command failed:[/bold red] {e.cmd}")
        sys.exit(1)

def get_partition_prefix(disk: str) -> str:
    """Returns 'p' if the disk ends in a number (nvme0n1 -> nvme0n1p), else nothing (sda -> sda)."""
    return f"{disk}p" if disk[-1].isdigit() else disk

def display_drives():
    """Fetches and displays available block devices."""
    output = run_cmd("lsblk -dpno NAME,SIZE,MODEL", shell=True, capture=True)
    table = Table(title="Available Drives", show_header=True, header_style="bold magenta")
    table.add_column("Path", style="cyan")
    table.add_column("Size", style="green")
    table.add_column("Model", style="yellow")
    
    for line in output.split('\n'):
        if line.strip():
            parts = line.split(maxsplit=2)
            if len(parts) == 3:
                table.add_row(parts[0], parts[1], parts[2])
            elif len(parts) == 2:
                table.add_row(parts[0], parts[1], "Unknown")
    console.print(table)

def main():
    console.print(Panel.fit("[bold cyan]🚀 Minimal NixOS Setup Manager[/bold cyan]"))

    disk = None
    boot_mode = None

    # --- Partitioning Setup ---
    if Confirm.ask("\nDo you want to setup partitions on a drive?", default=True):
        display_drives()
        
        disk = Prompt.ask("\nEnter the drive path to format (e.g., /dev/sda, /dev/vda)")
        if not os.path.exists(disk):
            console.print(f"[bold red]❌ Drive {disk} not found. Exiting.[/bold red]")
            sys.exit(1)

        part_prefix = get_partition_prefix(disk)

        boot_mode = Prompt.ask("Select Boot Mode", choices=["uefi", "bios"], default="uefi")
        fs_choice = Prompt.ask("Select Root Filesystem", choices=["ext4", "f2fs"], default="ext4")

        console.print(f"\n[bold red]⚠️  WARNING: This will DESTROY ALL DATA on {disk}.[/bold red]")
        if Confirm.ask("Are you absolutely sure?", default=False):
            
            with console.status(f"[bold green]Partitioning and Formatting {disk} for {boot_mode.upper()}...") as status:
                run_cmd("umount -R /mnt 2>/dev/null || true", shell=True, check=False)
                run_cmd(f"umount -R {part_prefix}* 2>/dev/null || true", shell=True, check=False)

                if boot_mode == "uefi":
                    run_cmd("parted", "-s", disk, "--", "mklabel", "gpt")
                    run_cmd("parted", "-s", disk, "--", "mkpart", "ESP", "fat32", "1MiB", "1024MiB")
                    run_cmd("parted", "-s", disk, "--", "set", "1", "esp", "on")
                    run_cmd("parted", "-s", disk, "--", "mkpart", "primary", "1024MiB", "100%")
                    
                    run_cmd("mkfs.fat", "-F", "32", "-n", "boot", f"{part_prefix}1")
                    run_cmd(f"mkfs.{fs_choice}", "-f" if fs_choice == "f2fs" else "-F", "-L" if fs_choice == "ext4" else "-l", "nixos", f"{part_prefix}2")

                    run_cmd("udevadm", "settle")
                    run_cmd("mount", "/dev/disk/by-label/nixos", "/mnt")
                    os.makedirs("/mnt/boot", exist_ok=True)
                    run_cmd("mount", "/dev/disk/by-label/boot", "/mnt/boot")

                elif boot_mode == "bios":
                    run_cmd("parted", "-s", disk, "--", "mklabel", "msdos")
                    run_cmd("parted", "-s", disk, "--", "mkpart", "primary", "ext4", "1MiB", "100%")
                    
                    run_cmd(f"mkfs.{fs_choice}", "-f" if fs_choice == "f2fs" else "-F", "-L" if fs_choice == "ext4" else "-l", "nixos", f"{part_prefix}1")

                    run_cmd("udevadm", "settle")
                    run_cmd("mount", "/dev/disk/by-label/nixos", "/mnt")
            
            console.print("[bold green]✅ Partitions created and mounted.[/bold green]")
        else:
            console.print("[yellow]Partitioning aborted.[/yellow]")
    else:
        console.print("[yellow]Skipping partitioning. (Assuming drives are mounted to /mnt)[/yellow]")

    # --- NixOS Configuration Generation ---
    if Confirm.ask("\nDo you want to run nixos-generate-config?", default=True):
        with console.status("[bold blue]Generating configuration..."):
            run_cmd("nixos-generate-config", "--root", "/mnt")
        console.print("[bold green]✅ Configuration generated at /mnt/etc/nixos/[/bold green]")

    # --- Final Instructions ---
    console.print("\n" + "="*60)
    console.print("[bold green]🎉 Setup phase complete![/bold green]")
    console.print("="*60 + "\n")
    console.print("Next steps:")
    console.print("1. Configure your system and bootloader by editing:")
    console.print("   [cyan]nano /mnt/etc/nixos/configuration.nix[/cyan]")
    console.print("\n2. Once configured, run the final install:")
    console.print("   [cyan]nixos-install[/cyan]")
    console.print("3. Reboot your system!")

if __name__ == "__main__":
    main()
