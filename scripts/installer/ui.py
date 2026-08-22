import os
import sys
from dataclasses import dataclass
from rich.panel import Panel
from rich.prompt import Prompt, Confirm
from rich.table import Table
from .utils import console, run_capture


@dataclass
class InstallConfig:
    disk: str
    part_prefix: str
    boot_mode: str
    fs_choice: str
    use_luks: bool
    use_impermanence: bool


def show_banner() -> None:
    console.print(Panel.fit("[bold cyan]🚀 NixOS Setup Manager[/bold cyan]"))


def display_drives() -> None:
    """Fetches and displays available block devices."""
    output = run_capture("lsblk -dpno NAME,SIZE,MODEL", shell=True)
    table = Table(
        title="Available Drives", show_header=True, header_style="bold magenta"
    )
    table.add_column("Path", style="cyan")
    table.add_column("Size", style="green")
    table.add_column("Model", style="yellow")

    for line in output.split("\n"):
        if line.strip():
            parts = line.split(maxsplit=2)
            if len(parts) == 3:
                table.add_row(parts[0], parts[1], parts[2])
            elif len(parts) == 2:
                table.add_row(parts[0], parts[1], "Unknown")
    console.print(table)


def prompt_install_config(part_prefix_fn) -> InstallConfig:
    """Gathers user configuration choices interactively."""
    disk = Prompt.ask("\nEnter the drive path to format (e.g., /dev/nvme0n1, /dev/sda)")
    if not os.path.exists(disk):
        console.print(f"[bold red]❌ Drive {disk} not found. Exiting.[/bold red]")
        sys.exit(1)

    part_prefix = part_prefix_fn(disk)
    boot_mode = Prompt.ask("Select Boot Mode", choices=["uefi", "bios"], default="uefi")
    fs_choice = Prompt.ask(
        "Select Root Filesystem", choices=["ext4", "f2fs", "btrfs"], default="ext4"
    )

    use_luks = False
    use_impermanence = False
    if fs_choice == "btrfs":
        use_luks = Confirm.ask("Enable LUKS2 encryption?", default=True)
        use_impermanence = Confirm.ask(
            "Use ephemeral root on tmpfs (Impermanence)?", default=False
        )

    return InstallConfig(
        disk=disk,
        part_prefix=part_prefix,
        boot_mode=boot_mode,
        fs_choice=fs_choice,
        use_luks=use_luks,
        use_impermanence=use_impermanence,
    )
