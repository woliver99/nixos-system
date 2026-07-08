import os
from pathlib import Path

TITLE="Reorganize repo"

def run(console):
    console.print(f"[cyan]Running Migration: {TITLE}...[/cyan]")
    
    structural_changes = {
        "nixos-system/features/": "nixos-system/modules/features/",
        "nixos-system/presets/": "nixos-system/modules/profiles/",
        "nixos-system/patches/": "nixos-system/modules/patches/",
    }

    try:
        migrate_configuration(structural_changes, console)
        console.print(f"[green]✅ Migration: {TITLE} ran successfully.[/green]")
        return True
    except Exception as e:
        console.print(f"[bold red]❌ Migration: {TITLE} failed with error:[/bold red] {e}")
        return False

def migrate_configuration(mappings: dict, console):
    """
    Scans files, prints matching lines (mimicking grep), and replaces paths.
    Bakes in dry-run safety via the 'MIGRATION_DRY_RUN' environment variable.
    Inputs:
        mappings (dict): { "old/plain/string": "new/plain/string" }
    """
    # 1. Baked-in Dry Run Detection
    dry_run = os.environ.get("MIGRATION_DRY_RUN", "0").lower() in ("1", "true", "yes")
    
    mode_label = "[DRY RUN - PREVIEW ONLY]" if dry_run else "[LIVE RUN - MODIFYING FILES]"
    console.print(f"=== Migration Engine Active: {mode_label} ===")

    # 2. Recursively find target files
    for path in Path(".").rglob("*"):
        # Filters: Skip hidden items and skip the 'nixos-system' tracking directory itself
        if any(part.startswith(".") for part in path.parts) or "nixos-system" in path.parts:
            continue
        if not path.is_file():
            continue
            
        try:
            content = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, PermissionError):
            continue  # Safely ignore binaries or restricted files

        updated_content = content
        file_was_modified = False

        # 3. Perform literal string matching and replacements
        for search_str, replace_str in mappings.items():
            if search_str in updated_content:
                # Mimic 'grep -H' by printing the file path, line number, and matching content
                for line_num, line in enumerate(content.splitlines(), 1):
                    if search_str in line:
                        # Print the original current line
                        console.print(f"{path}:{line_num}: {line.strip()}")
                        
                        # Generate and print the updated version directly below it
                        new_line = line.replace(search_str, replace_str)
                        console.print(f"  └──> [green]{new_line.strip()}[/green]")
                
                # Execute the direct string swap
                updated_content = updated_content.replace(search_str, replace_str)
                file_was_modified = True

        # 4. Save changes back to disk only if live
        if file_was_modified and not dry_run:
            path.write_text(updated_content, encoding="utf-8")
            console.print(f"      ↳ ✅ Successfully updated contents of: {path}\n")
        elif file_was_modified and dry_run:
            console.print(f"      ↳ ⚡ [Dry-Run] Would modify: {path}\n")
