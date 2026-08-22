import subprocess
import sys
from rich.console import Console

console = Console()


def run_cmd(*cmd: str, shell: bool = False, check: bool = True) -> None:
    """Executes a system command without capturing output."""
    try:
        subprocess.run(
            cmd if not shell else cmd[0], shell=shell, check=check, text=True
        )
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]❌ Command failed:[/bold red] {e.cmd}")
        sys.exit(1)


def run_capture(*cmd: str, shell: bool = False, check: bool = True) -> str:
    """Executes a command and returns stripped stdout."""
    try:
        result = subprocess.run(
            cmd if not shell else cmd[0],
            shell=shell,
            check=check,
            text=True,
            capture_output=True,
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]❌ Command failed:[/bold red] {e.cmd}")
        sys.exit(1)


def get_partition_prefix(disk: str) -> str:
    """Returns 'p' if the disk ends in a digit (nvme0n1 -> nvme0n1p), else nothing (sda -> sda)."""
    return f"{disk}p" if disk[-1].isdigit() else disk
