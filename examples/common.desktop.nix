{ ... }:

{
  imports = [
    # -- Common --
    ./nixos-system/common # Common config for every system

    # -- Presets --
    #./nixos-system/presets/hardware/msi-gl65-leopard-10sfk.nix # Import your hardware preset here
    ./nixos-system/presets/users/user.nix # Import your user here
    #./nixos-system/presets/users/woliver99.nix # Admin user
    ./nixos-system/presets/editor/nixvim # Import your editor preset here (comment out if all you need is nano since thats installed by default)
    ./nixos-system/presets/display-manager/gnome.nix # Import your desktop environment here
    ./nixos-system/presets/apps/full.nix # Import your apps preset here (options: essentials, full, developer)

    # -- Modules --
    #./nixos-system/modules/flash-storage.nix # Adds optimisations for sd card storage lifespan

    # -- Features --
    ./nixos-system/features/firewall.nix # Enables the system firewall (might break some apps if not configured properly)
    ./nixos-system/features/auto-update.nix # System auto updates every week and waits for a reboot to apply changes
    ./nixos-system/features/flatpak.nix # Installs Flatpak for easy sandbox app installs for users
    ./nixos-system/features/printers.nix # Adds support for most printers
    ./nixos-system/features/vpn.nix # Adds support for most vpns
    ./nixos-system/features/ssh.nix # Installs ssh only accessible via public keys (disables password logins)
    #./nixos-system/features/passwordless-sudo.nix # Disables needing password for sudo, low-key unsafe
    #./nixos-system/features/remote-desktop.nix # Installs Gnome remote desktop which works over rdp (should only be enabled when using Gnome)
    #./nixos-system/features/steam.nix # Installs Steam
    #./nixos-system/features/obs.nix # Installs OBS
    #./nixos-system/features/drawing-tablet.nix # Adds support for most drawing tablets
    #./nixos-system/features/bitwarden-ssh-agent.nix # Allows the bitwarden flatpak to act as a ssh agent for the system
  ];

  #users.users.woliver99.hidden = true; # Hide admin user from desktop
}
