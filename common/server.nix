{ lib, ... }:

{
  imports = [
    # -- Common --
    ./default.nix # Common config for every system

    # -- Modules --
    ../modules/profiles/apps/essentials.nix # Select your apps preset here (options: essentials, full, developer)
    ../modules/editor/nixvim # Neovim set up with a custom config\
    ../modules/users/woliver99.nix # Import your user preset here

    # Features
    ../modules/features/firewall.nix # Enables the system firewall (might break some apps if not configured properly)
    #../modules/features/auto-update.nix # System auto updates and waits for a reboot to apply changes
    ../modules/features/ssh.nix # Installs ssh only accessible via public keys (disables password logins)
    ../modules/features/podman.nix
  ];

  mySystem.proxmox.enable = lib.mkDefault true;
}
