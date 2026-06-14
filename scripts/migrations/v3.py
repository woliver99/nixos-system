import subprocess

def run(console):
    console.print("[cyan]Running Migration 3: Cleaning up nixvim channel...[/cyan]")
    
    try:
        # Delete the channel
        subprocess.run(["nix-channel", "--remove", "nixvim"], check=True)
        
        # Trigger an update to clear the channel out of the system binary cache evaluation
        subprocess.run(["nix-channel", "--update"], check=True)
        
        console.print("[green]✅ nixvim channel removed successfully.[/green]")
    except subprocess.CalledProcessError:
        # If it fails (e.g., the channel didn't exist in the first place), we log it and move on safely
        console.print("[yellow]⚠️ Could not delete channel (it may already be removed). Skipping safely.[/yellow]")
        
    return True
