{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.maple.defaults;
in
{
  imports = [
    ./options
  ];

  options.maple.defaults = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Things every system should have.";
    };
  };

  config = lib.mkIf cfg.enable {
    maple = {
      # Give myself access since I configure all the systems
      users.woliver99 = {
        enable = lib.mkDefault true;
        hidden = lib.mkDefault true;
      };
      profiles = {
        tmux.enable = lib.mkDefault true;
        neovim.enable = lib.mkDefault true;
        ssh.enable = lib.mkDefault true; # So I can access it remotely
      };
    };

    features = {
      cleanup.enable = lib.mkDefault true;
      autoUpdate.enable = lib.mkDefault true;
    };

    maplenetwork.localCache.enable = lib.mkDefault true;

    time.timeZone = lib.mkDefault "America/Toronto"; # Time zone
    i18n.defaultLocale = lib.mkDefault "en_CA.UTF-8"; # Internationalisation properties
    nixpkgs.config.allowUnfree = lib.mkDefault true; # Allow proprietary software to be installed

    # Keymap
    services.xserver.xkb = {
      layout = lib.mkDefault "us";
      variant = lib.mkDefault "";
    };

    programs.bash.shellAliases = {
      editconfig = "cd /etc/nixos/";
      explorer = "(xdg-open . > /dev/null 2>&1 &)";
      sys-update = "editconfig &&  sudo bash ./nixos-system/scripts/update.sh";
      sys-dryupdate = "editconfig && sudo bash ./nixos-system/scripts/update.sh --dry-run";
    };

    nix.settings.auto-optimise-store = lib.mkDefault true; # No reason not to use this

    networking.networkmanager.enable = lib.mkDefault true;
    networking.firewall.enable = lib.mkDefault true;
    services.timesyncd.enable = lib.mkDefault false;
    services.chrony.enable = lib.mkDefault true;

    programs.direnv.enable = lib.mkDefault true;

    programs.git = {
      enable = lib.mkDefault true;
      config.init.defaultBranch = "main";
    };

    # Trust Github for ssh
    programs.ssh.knownHosts = {
      "github.com" = {
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      };
    };

    environment.systemPackages = with pkgs; [
      zip
      unzip
      wget
      python313
      htop
    ];
  };
}
