# Use this template outside the nixos-system repository (ex: /etc/nixos/configuration.nix when the repository exists at /etc/nixos/nixos-system/)

{ ... }:

{
  imports = [
    ./hardware-configuration.nix

    # -- Presets --
    ./nixos-system/presets/hardware/proxmox.nix # Import your hardware preset here
    ./nixos-system/presets/users/woliver99.nix # Import your user preset here
    ./nixos-system/presets/editor/nixvim/ssh.nix # Import your editor preset here (nano is installed by default)
    ./nixos-system/presets/apps/essentials.nix # Import your apps preset here (options: essentials, full, developer)

    # -- Features --
    ./nixos-system/features/firewall.nix # Enables the system firewall (might break some apps if not configured properly)
    ./nixos-system/features/ssh.nix # Installs ssh only accessible via public keys (disables password logins)
    ./nixos-system/features/shell-shortcuts.nix # Usefull shell shortcuts I like to have in my terminal
    ./nixos-system/features/passwordless-sudo.nix
  ];

  networking.hostName = "nixos"; # Device name
  time.timeZone = "America/Toronto"; # Time zone
  i18n.defaultLocale = "en_CA.UTF-8"; # Internationalisation properties
  nixpkgs.config.allowUnfree = true; # Allow proprietary software to be installed (recommended to be enable)

  # Keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  boot.loader.grub = {
    enable = true;
    #device = "/dev/sda";
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024;
    }
  ];

  #system.stateVersion = "25.05"; # UPDATE TO YOUR VERSION
}
