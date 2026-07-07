{ ... }:

{
  imports = [
    # -- Common --
    ./default.nix # Common config for every system

    # -- Presets --
    ../presets/users/user.nix # Import your user here
    ../presets/users/woliver99.nix # Admin user
    ../presets/editor/nixvim # Import your editor preset here (comment out if all you need is nano since thats installed by default)
    ../presets/display-manager/gnome.nix # Import your desktop environment here
    ../presets/apps/full.nix # Import your apps preset here (options: essentials, full, developer)

    # -- Modules --
    ../modules/zattoo # Zattoo tv app

    # -- Features --
    ../features/firewall.nix # Enables the system firewall (might break some apps if not configured properly)
    ../features/auto-update.nix # System auto updates every week and waits for a reboot to apply changes
    ../features/flatpak.nix # Installs Flatpak for easy sandbox app installs for users
    #../features/printers.nix # Adds support for most printers
    #../features/vpn.nix # Adds support for most vpns
    ../features/ssh.nix # Installs ssh only accessible via public keys (disables password logins)
    #../features/remote-desktop.nix # Installs Gnome remote desktop which works over rdp (should only be enabled when using Gnome)
    #../features/steam.nix # Installs Steam
    #../features/obs.nix # Installs OBS
    #../features/drawing-tablet.nix # Adds support for most drawing tablets
  ];

  users.users.woliver99.hidden = true; # Hide admin user from desktop
}
