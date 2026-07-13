{ ... }:

{
  imports = [
    # -- Common --
    ./default.nix # Common config for every system

    # -- Modules --
    ../modules/editor/nixvim # Neovim set up with a custom config
    ../modules/zattoo # Zattoo tv app

    # Users
    ../modules/profiles/users/user.nix # Unprivilaged user
    ../modules/profiles/users/woliver99.nix # Admin user

    # Profiles
    ../modules/profiles/display-manager/gnome.nix # Import your desktop environment here
    ../modules/profiles/apps/full.nix # Import your apps profile here (options: essentials, full, developer)

    # Features
    ../modules/features/firewall.nix # Enables the system firewall
    ../modules/features/auto-update.nix # System auto updates every week and waits for a reboot to apply changes
    ../modules/features/flatpak.nix # Installs Flatpak for easy sandbox app installs for users
    #../modules/features/printers.nix # Adds support for most printers
    #../modules/features/vpn.nix # Adds support for most vpns
    ../modules/features/ssh.nix # Installs ssh only accessible via public keys (disables password logins)
    #../modules/features/remote-desktop.nix # Installs Gnome remote desktop which works over rdp
    #../modules/features/steam.nix # Installs Steam
    #../modules/features/obs.nix # Installs OBS
    #../modules/features/drawing-tablet.nix # Adds support for most drawing tablets
  ];

  users.users.woliver99.hidden = true; # Hide admin user from desktop
}
