import os
import sys
import subprocess
import time
from rich.console import Console
from rich.prompt import Prompt
from rich.table import Table

console = Console()


def run_cmd(
    cmd: list[str], input_data: str | None = None
) -> subprocess.CompletedProcess:
    """Runs a command, optionally passing string inputs to stdin."""
    return subprocess.run(
        cmd,
        input=input_data,
        text=True,
        capture_output=True,
    )


def check_mounts(
    boot_mode: str,
    fs: str,
    use_luks: bool = False,
    use_impermanence: bool = False,
) -> tuple[bool, str]:
    """Strictly verifies partition table layout and all expected mount points."""
    mounts: dict[str, str] = {}
    with open("/proc/mounts", "r") as f:
        for line in f:
            parts = line.split()
            if len(parts) >= 3:
                mounts[parts[1]] = parts[2]

    # 1. Verify boot partition for UEFI
    if boot_mode == "uefi":
        if "/mnt/boot" not in mounts:
            return False, "Missing /mnt/boot mount"
        if mounts["/mnt/boot"] not in ["vfat", "msdos"]:
            return False, f"Expected vfat for /mnt/boot, got {mounts['/mnt/boot']}"

    # 2. Verify non-Btrfs mounts
    if fs in ["ext4", "f2fs"]:
        if "/mnt" not in mounts:
            return False, "Missing /mnt root mount"
        if mounts["/mnt"] != fs:
            return False, f"Expected {fs} for /mnt, got {mounts['/mnt']}"
        return True, "PASSED"

    # 3. Verify Btrfs mount variations
    if fs == "btrfs":
        # Shared subvolume mounts across all Btrfs setups
        if "/mnt/home" not in mounts or mounts["/mnt/home"] != "btrfs":
            return False, "Missing or invalid /mnt/home subvolume mount"
        if "/mnt/nix" not in mounts or mounts["/mnt/nix"] != "btrfs":
            return False, "Missing or invalid /mnt/nix subvolume mount"

        if use_impermanence:
            if "/mnt" not in mounts or mounts["/mnt"] != "tmpfs":
                return False, f"Expected tmpfs on /mnt, got {mounts.get('/mnt')}"
            if "/mnt/persist" not in mounts or mounts["/mnt/persist"] != "btrfs":
                return False, "Missing /mnt/persist subvolume mount"
            if "/mnt/etc/nixos" not in mounts:
                return False, "Missing /mnt/etc/nixos bind mount"
        else:
            if "/mnt" not in mounts or mounts["/mnt"] != "btrfs":
                return False, f"Expected btrfs on /mnt, got {mounts.get('/mnt')}"

        if use_luks and not os.path.exists("/dev/mapper/enc-pv"):
            return False, "LUKS container /dev/mapper/enc-pv is not open"

        return True, "PASSED"

    return False, "Unknown filesystem configuration"


def clean_disk(disk: str) -> None:
    """Force unmounts everything and closes LUKS containers cleanly."""
    disk_name = disk.replace("/dev/", "")
    subprocess.run("umount -R /mnt 2>/dev/null || true", shell=True)
    subprocess.run(f"umount -R /dev/{disk_name}* 2>/dev/null || true", shell=True)
    subprocess.run("cryptsetup close enc-pv 2>/dev/null || true", shell=True)


def main() -> None:
    if os.geteuid() != 0:
        console.print("[bold red]❌ Run as root (sudo).[/bold red]")
        sys.exit(1)

    subprocess.run("lsblk -dpno NAME,SIZE,MODEL", shell=True)
    disk = Prompt.ask("\nEnter the target drive path to run tests on (e.g. /dev/vda)")

    if not os.path.exists(disk):
        console.print(f"[bold red]❌ Disk {disk} not found.[/bold red]")
        sys.exit(1)

    # Test matrix combinations
    matrix = [
        {"boot": "uefi", "fs": "ext4", "luks": False, "impermanence": False},
        {"boot": "uefi", "fs": "f2fs", "luks": False, "impermanence": False},
        {"boot": "bios", "fs": "ext4", "luks": False, "impermanence": False},
        {"boot": "uefi", "fs": "btrfs", "luks": False, "impermanence": False},
        {"boot": "uefi", "fs": "btrfs", "luks": True, "impermanence": False},
        {"boot": "uefi", "fs": "btrfs", "luks": False, "impermanence": True},
        {"boot": "uefi", "fs": "btrfs", "luks": True, "impermanence": True},
    ]

    results = Table(
        title="Installation Automation Test Results",
        show_header=True,
        header_style="bold magenta",
    )
    results.add_column("Boot", style="cyan")
    results.add_column("Filesystem", style="magenta")
    results.add_column("LUKS", style="yellow")
    results.add_column("Imperm", style="blue")
    results.add_column("Execution", style="green")
    results.add_column("Mount Verification", style="bold")

    for run in matrix:
        boot = run["boot"]
        fs = run["fs"]
        luks = run["luks"]
        imperm = run["impermanence"]

        desc = f"{boot.upper()} | {fs.upper()} | LUKS: {luks} | Imperm: {imperm}"
        console.print(f"\n[bold blue]🤖 Testing: {desc}[/bold blue]")
        clean_disk(disk)

        # Build simulated stdin inputs according to prompt order
        inputs = ["y", disk, boot, fs]

        if fs == "btrfs":
            inputs.append("y" if luks else "n")
            inputs.append("y" if imperm else "n")

        inputs.append("y")  # Confirm drive wipe

        # Passphrase inputs for Enter and Confirm prompts
        if fs == "btrfs" and luks:
            inputs.extend(["testpass123", "testpass123"])

        inputs.append("n")  # Skip nixos-generate-config during rapid test runs

        simulated_inputs = "\n".join(inputs) + "\n"
        proc = run_cmd(
            ["python3", "-m", "scripts.installer.main"], input_data=simulated_inputs
        )

        exec_status = (
            "[green]SUCCESS[/green]" if proc.returncode == 0 else "[red]FAILED[/red]"
        )

        subprocess.run(["udevadm", "settle"])
        time.sleep(1)

        is_valid, message = check_mounts(
            boot_mode=boot, fs=fs, use_luks=luks, use_impermanence=imperm
        )
        mount_status = (
            "[green]PASSED[/green]" if is_valid else f"[red]FAILED ({message})[/red]"
        )

        results.add_row(
            boot.upper(),
            fs.upper(),
            "YES" if luks else "NO",
            "YES" if imperm else "NO",
            exec_status,
            mount_status,
        )

        if proc.returncode != 0 or not is_valid:
            console.print(f"[bold red]Stderr Output:[/bold red]\n{proc.stderr}")
            console.print(f"[bold yellow]Stdout Output:[/bold yellow]\n{proc.stdout}")

    clean_disk(disk)
    console.print("\n")
    console.print(results)


if __name__ == "__main__":
    main()
