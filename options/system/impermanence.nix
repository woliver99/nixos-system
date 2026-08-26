{
  config,
  lib,
  ...
}:

let
  cfg = config.maple.system.impermanence;
  hasFprintd = config.services.fprintd.enable;
  hasFlatpak = config.services.flatpak.enable;
  hasSecureBoot = config.boot.loader.limine.secureBoot.enable;
in
{
  options.maple.system.impermanence = {
    enable = lib.mkEnableOption "My working impermanence setup";
  };

  config = lib.mkIf cfg.enable {
    # sudo mkdir -p /persist/passwords && nix-shell -p mkpasswd --run "mkpasswd -m yescrypt" | sudo tee /persist/passwords/woliver99 && sudo chmod 600 /persist/passwords/woliver99
    # users.users.woliver99.hashedPasswordFile = "/persist/passwords/woliver99";

    maple.system = {
      swap.path = lib.mkDefault "/persist/swapfile";
      hibernate.resumeDevice = lib.mkDefault (config.fileSystems."/persist".device or null);
    };

    # Disable the first-run lecture on ephemeral tmpfs root
    security.sudo.extraConfig = ''
      Defaults lecture = never
    '';

    fileSystems = lib.mkMerge [

      {
        "/".options = [
          "mode=755"
          "size=8G"
        ];
      }

      {
        "/persist".neededForBoot = true;
      }

      {
        # Wi-Fi networks and passwords
        "/etc/NetworkManager/system-connections" = {
          device = "/persist/etc/NetworkManager/system-connections";
          fsType = "none";
          options = [ "bind" ];
        };
      }

      {
        # Persist NetworkManager state (Wi-Fi on/off switch, timestamps)
        "/var/lib/NetworkManager" = {
          device = "/persist/var/lib/NetworkManager";
          fsType = "none";
          options = [ "bind" ];
        };
      }

      {
        # Paired Bluetooth devices
        "/var/lib/bluetooth" = {
          device = "/persist/var/lib/bluetooth";
          fsType = "none";
          options = [ "bind" ];
        };
      }

      {
        # Persistent systemd journal logs
        "/var/log" = {
          device = "/persist/var/log";
          fsType = "none";
          options = [ "bind" ];
          neededForBoot = true;
        };
      }

      {
        # Systemd timer states, backlight levels, rfkill (airplane mode) state
        "/var/lib/systemd" = {
          device = "/persist/var/lib/systemd";
          fsType = "none";
          options = [ "bind" ];
        };
      }

      (lib.mkIf hasFprintd {
        "/var/lib/fprint" = {
          device = "/persist/var/lib/fprint";
          fsType = "none";
          options = [ "bind" ];
        };
      })

      (lib.mkIf hasSecureBoot {
        # Save secureboot keys
        "/var/lib/sbctl" = {
          device = "/persist/var/lib/sbctl";
          fsType = "none";
          options = [ "bind" ];
        };
      })

      (lib.mkIf hasFlatpak {
        # System-wide Flatpaks
        "/var/lib/flatpak" = {
          device = "/persist/var/lib/flatpak";
          fsType = "none";
          options = [ "bind" ];
        };
      })
    ];

    # Preserves D-Bus identity, DHCP IP leases, and journal correlation
    environment.etc."machine-id".source = "/persist/etc/machine-id";

    # Automatically create backing directories on /persist if they don't exist yet
    systemd.tmpfiles.rules = [
      "d /persist/etc/NetworkManager/system-connections 0700 root root -"
      "d /persist/var/lib/NetworkManager 0700 root root -"
      "d /persist/var/lib/bluetooth 0700 root root -"
      "d /persist/var/log 0755 root root -"
      "d /persist/var/lib/systemd 0755 root root -"
      "d /persist/etc 0755 root root -"
    ]
    ++ lib.optional hasFprintd "d /persist/var/lib/fprint 0700 root root -"
    ++ lib.optional hasSecureBoot "d /persist/var/lib/sbctl 0700 root root -"
    ++ lib.optional hasFlatpak "d /persist/var/lib/flatpak 0755 root root -";

  };
}
