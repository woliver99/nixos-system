{ ... }:

{
  imports = [
    # -- Presets --
    #./nixos-system/presets/hardware/proxmox.nix # Import your hardware preset here
    ./nixos-system/presets/users/woliver99.nix # Import your user preset here
    ./nixos-system/presets/editor/nixvim # Import your editor preset here (nano is installed by default)
    ./nixos-system/presets/apps/essentials.nix # Import your apps preset here (options: essentials, full, developer)

    # -- Modules --
    ./nixos-system/modules/common.nix # Common config for every system
    #./nixos-system/modules/flash-storage.nix # Adds optimisations for sd card storage lifespan

    # -- Features --
    ./nixos-system/features/firewall.nix # Enables the system firewall (might break some apps if not configured properly)
    ./nixos-system/features/ssh.nix # Installs ssh only accessible via public keys (disables password logins)
    ./nixos-system/features/passwordless-sudo.nix # Disables needing password for sudo, low-key unsafe
  ];

  time.timeZone = "America/Toronto"; # Time zone
  i18n.defaultLocale = "en_CA.UTF-8"; # Internationalisation properties
  nixpkgs.config.allowUnfree = true; # Allow proprietary software to be installed (recommended to be enable)

  # Keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
}
