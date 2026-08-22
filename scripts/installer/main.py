from rich.prompt import Confirm
from .utils import console, run_cmd, get_partition_prefix
from .ui import show_banner, display_drives, prompt_install_config
from .disk import (
    cleanup_previous_mounts,
    setup_uefi_partitions,
    setup_bios_partitions,
    setup_btrfs,
    setup_standard_fs,
)


def main() -> None:
    show_banner()

    if Confirm.ask("\nDo you want to setup partitions on a drive?", default=True):
        display_drives()
        cfg = prompt_install_config(get_partition_prefix)

        console.print(
            f"\n[bold red]⚠️  WARNING: This will DESTROY ALL DATA on {cfg.disk}.[/bold red]"
        )
        if Confirm.ask("Are you absolutely sure?", default=False):
            cleanup_previous_mounts(cfg.part_prefix)

            if cfg.boot_mode == "uefi":
                setup_uefi_partitions(cfg.disk, cfg.part_prefix)
                if cfg.fs_choice == "btrfs":
                    setup_btrfs(cfg)
                else:
                    setup_standard_fs(cfg)
            elif cfg.boot_mode == "bios":
                setup_bios_partitions(cfg.disk)
                setup_standard_fs(cfg)

            console.print("[bold green]✅ Partitions created and mounted.[/bold green]")
        else:
            console.print("[yellow]Partitioning aborted.[/yellow]")
    else:
        console.print(
            "[yellow]Skipping partitioning. (Assuming drives are mounted to /mnt)[/yellow]"
        )

    if Confirm.ask("\nDo you want to run nixos-generate-config?", default=True):
        with console.status("[bold blue]Generating configuration..."):
            run_cmd("nixos-generate-config", "--root", "/mnt")
        console.print(
            "[bold green]✅ Configuration generated at /mnt/etc/nixos/[/bold green]"
        )

    console.print("\n" + "=" * 60)
    console.print("[bold green]🎉 Setup phase complete![/bold green]")
    console.print("=" * 60 + "\n")
    console.print("Next steps:")
    console.print(
        "1. Edit system configuration: [cyan]nano /mnt/etc/nixos/configuration.nix[/cyan]"
    )
    console.print("2. Run installation:          [cyan]nixos-install[/cyan]")
    console.print("3. Reboot your system!")


if __name__ == "__main__":
    main()
