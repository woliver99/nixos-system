import os
import sys
import re
from pathlib import Path

from rich.console import Console
from rich.prompt import Prompt

console = Console()

# --- Absolute Path Definitions ---
LOCAL_VERSION_FILE = Path("./nixos-system.version")
MIGRATIONS_DIR = Path("./nixos-system/scripts/migrations")

def get_available_migrations():
    """Scans the migrations folder and returns a dict mapping integers to file paths.
    Looks for files matching patterns like v1.py, v2.py, v12.py"""
    migrations = {}
    if not MIGRATIONS_DIR.exists():
        return migrations
        
    for file in MIGRATIONS_DIR.glob("v*.py"):
        match = re.match(r"^v(\d+)\.py$", file.name)
        if match:
            version_num = int(match.group(1))
            migrations[version_num] = file
            
    return migrations

def main():
    console.print("[bold blue]System Update Manager[/bold blue]\n")
    
    available_migrations = get_available_migrations()
    
    # The target repo version is simply the highest migration number found in the folder
    repo_version = max(available_migrations.keys()) if available_migrations else 0
    
    # --- New Machine / Missing Version File Check ---
    if not LOCAL_VERSION_FILE.exists():
        console.print("[yellow]🆕 No local version file found (Fresh System Setup).[/yellow]")
        console.print(f"Setting local system version to the latest: [bold]{repo_version}[/bold]")
        
        # Initialize the file with the highest migration number
        LOCAL_VERSION_FILE.write_text(str(repo_version))
        
        console.print("[green]✅ System initialized to latest baseline. Exiting migration phase.[/green]")
        sys.exit(0)

    # If the file exists, parse it normally
    try:
        local_version = int(LOCAL_VERSION_FILE.read_text().strip())
    except ValueError:
        local_version = 0
    
    console.print(f"Current Machine Version: [bold]{local_version}[/bold]")
    console.print(f"Target Submodule Version: [bold]{repo_version}[/bold]")
    
    # Run pending migrations sequentially
    if local_version < repo_version:
        console.print(f"\n[yellow]⏳ Discovered {repo_version - local_version} pending system migration(s)...[/yellow]")
        
        for v in range(local_version + 1, repo_version + 1):
            if v in available_migrations:
                console.print(f"\n[bold]🚀 Executing Migration Step v{v}...[/bold]")
                
                migration_file = available_migrations[v]
                
                try:
                    namespace = {}
                    exec(migration_file.read_text(), namespace)
                    
                    if "run" in namespace:
                        success = namespace["run"](console)
                        
                        if success:
                            LOCAL_VERSION_FILE.write_text(str(v))
                            console.print(f"[bold green]✅ Successfully migrated to version {v}.[/bold green]")
                        else:
                            console.print(f"\n[bold red]🛑 Update halted at version {v}. Manual action required.[/bold red]")
                            sys.exit(1)
                    else:
                        console.print(f"[red]❌ Migration file {migration_file.name} is missing the 'run(console)' function.[/red]")
                        sys.exit(1)
                        
                except Exception as e:
                    console.print(f"[bold red]❌ Migration script crashed with error:[/bold red] {e}")
                    sys.exit(1)
            else:
                LOCAL_VERSION_FILE.write_text(str(v))

    elif local_version == repo_version:
        console.print("[green]✨ No new migrations to run. Processing normal configuration updates.[/green]")
        
    else:
        console.print("[bold magenta]❓ Machine version is ahead of available migrations. Skipping.[/bold magenta]")

    # Final Stage: Run the NixOS rebuild
    console.print("")

    action = Prompt.ask(
        "[bold yellow]❓ How would you like to apply the rebuild?[/bold yellow]",
        choices=["switch", "boot", "skip"],
        default="switch"
    )

    if action in ["switch", "boot"]:
        console.print(f"\n[bold green]⚙️ Running nixos-rebuild {action}...[/bold green]")
        ret = os.system(f"nixos-rebuild {action}")
        
        if ret == 0:
            console.print("\n[bold green]🎉 System update completely successful![/bold green]")
        else:
            console.print("\n[bold red]❌ NixOS build failed. Check logs above.[/bold red]")
            sys.exit(1)
    else:
        console.print("\n[yellow]↩️ Rebuild skipped by user. System files updated, but new config is not active.[/yellow]")
        sys.exit(0)

if __name__ == "__main__":
    main()
