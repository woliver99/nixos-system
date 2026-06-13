import subprocess

def run(console):
    console.print("[cyan]Running Migration 1: Moving nixos-hardware location...[/cyan]")
    
    cmd = "find . -type f -not -path '*/.*' -not -path './nixos-system/pkgs/*' -exec sed -i 's|../../pkgs/nixos-hardware/|../../pkgs/nixos-hardware/|g' {} +"

    try:
        subprocess.run(cmd, shell=True, check=True)
        console.print("[green]✅ Paths updated successfully via find/sed.[/green]")
        return True
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]❌ Command failed with exit code:[/bold red] {e.returncode}")
        return False
