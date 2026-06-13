import subprocess

def run(console):
    console.print("[cyan]Running Migration 2: Update printer feature path...[/cyan]")
    
    cmd = r"find . -type f -not -path '*/.*' -not -path './nixos-system/*' -exec sed -i 's|\./nixos-system/features/printers\b|\./nixos-system/features/printers.nix|g' {} +"

    try:
        subprocess.run(cmd, shell=True, check=True)
        console.print("[green]✅ Paths updated successfully.[/green]")
        return True
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]❌ Command failed with exit code:[/bold red] {e.returncode}")
        return False
