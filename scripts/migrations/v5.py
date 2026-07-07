import subprocess

def run(console):
    console.print("[cyan]Running Migration: Updating common configs...[/cyan]")
    
    # 1. Define the target paths (escaping regex characters where necessary)
    search_pattern = r'nixos-system/modules/common\.nix'
    replace_string = r'nixos-system/common'
    
    # 2. Define find filters
    exclude_hidden = r"-not -path '*/.*'"
    exclude_system = r"-not -path './nixos-system/*'"
    
    # 3. Construct the pipeline using clean variable blocks
    # - The first -exec (grep) prints the matching file names and lines
    # - The second -exec (sed) executes the in-place replacement
    cmd = (
        f"find . -type f {exclude_hidden} {exclude_system} "
        f"-exec grep -H '{search_pattern}' {{}} \\; "
        f"-exec sed -i 's|{search_pattern}|{replace_string}|g' {{}} +"
    )

    try:
        # Grep output will stream directly to your console log in real-time
        subprocess.run(cmd, shell=True, check=True)
        console.print("[green]✅ Updating common configs updated successfully.[/green]")
        return True
    except subprocess.CalledProcessError as e:
        console.print(f"[bold red]❌ Command failed with exit code:[/bold red] {e.returncode}")
        return False
