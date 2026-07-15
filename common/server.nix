{ lib, ... }:

{
  imports = [
    # -- Common --
    ./default.nix # Common config for every system

    # -- Modules --
    ../modules/editor/nixvim # Neovim set up with a custom config

    # Users
    ../modules/users/woliver99.nix

    # Profiles
    ../modules/profiles/apps/essentials.nix

    # Features
    ../modules/features/firewall.nix  
    #../modules/features/auto-update.nix # Auto updates weekly and waits for a reboot to apply changes
    ../modules/features/ssh.nix
    ../modules/features/podman.nix
  ];

  profiles.proxmox.enable = lib.mkDefault true;
  nix.settings.auto-optimise-store = true;
}
