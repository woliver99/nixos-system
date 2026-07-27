{ config, lib, ... }:

with lib;

let
  cfgCleanup = config.features.cleanup;
  cfgAutoUpdate = config.features.autoUpdate;
in
{
  options.features = {
    cleanup = {
      enable = mkEnableOption "automated garbage collection and store optimization";
    };
    autoUpdate = {
      enable = mkEnableOption "automated NixOS system upgrades";
    };
  };

  config = mkMerge [
    # Cleanup Configuration (GC + Optimise)
    (mkIf cfgCleanup.enable {
      nix.gc = {
        automatic = mkDefault true;
        options = mkDefault "--delete-older-than 14d";
        dates = mkDefault "Sat *-*-* 04:00:00";
        randomizedDelaySec = mkDefault "30m";
      };

      nix.optimise = {
        automatic = mkDefault true;
        dates = [ "Sat *-*-* 05:00:00" ];
        randomizedDelaySec = mkDefault "30m";
      };

      systemd.services.nix-gc.serviceConfig = {
        Nice = 19;
        IOSchedulingClass = "idle";
      };

      systemd.services.nix-optimise.serviceConfig = {
        Nice = 19;
        IOSchedulingClass = "idle";
      };
    })

    # Auto-Update Configuration
    (mkIf cfgAutoUpdate.enable {
      system.autoUpgrade = {
        enable = mkDefault true;
        operation = mkDefault "boot";
        allowReboot = mkDefault false;
        dates = mkDefault "Sat *-*-* 02:00:00";
        randomizedDelaySec = mkDefault "1h";
      };

      systemd.services.nixos-upgrade.serviceConfig = {
        Nice = 19;
        IOSchedulingClass = "idle";
      };
    })
  ];
}
