import subprocess

def run(console):
    console.print("[cyan]Running Migration 1: Moving nixos-hardware location...[/cyan]")
    
    cmd = r"find . -type f -not -path '*/.*' -not -path './nixos-system/*' -exec sed -i 's|nixos-system/nixos-hardware/|nixos-system/pkgs/nixos-hardware/|g' {} +"

    try:
        subprocess.run(cmd, shell=True, check=True)
        subprocess.run("rm -rf ./nixos-system/nixos-hardware/", shell=True, check=True)
        console.print("[green]✅ Paths updated successfully.[/green]")
        return True
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]❌ Command failed with exit code:[/bold red] {e.returncode}")
        return False
