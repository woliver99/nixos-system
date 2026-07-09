{ ... }:

{
  imports = [
    # -- Common --
    ./nixos-system/common # Common config for every system

    # -- Modules --
    ./nixos-system/modules/profiles/apps/essentials.nix # Select your apps preset here (options: essentials, full, developer)
    ./nixos-system/modules/editor/nixvim # Neovim set up with a custom config\
    ./nixos-system/modules/users/woliver99.nix # Import your user preset here

    # Features
    ./nixos-system/modules/features/firewall.nix # Enables the system firewall (might break some apps if not configured properly)
    #./nixos-system/modules/features/auto-update.nix # System auto updates and waits for a reboot to apply changes
    ./nixos-system/modules/features/ssh.nix # Installs ssh only accessible via public keys (disables password logins)
    ./nixos-system/modules/features/podman.nix
  ];

  # Prevent OOM
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 2*1024; # 2GB
    }
  ];
}
