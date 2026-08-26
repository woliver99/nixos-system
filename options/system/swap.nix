{ config, lib, ... }:
let
  cfg = config.maple.system.swap;
in
{
  options.maple.system.swap = {
    enable = lib.mkEnableOption "declarative swap file";

    path = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/swapfile";
      description = "Path to the swap file.";
    };

    sizeGb = lib.mkOption {
      type = lib.types.int;
      default = null;
      description = "Swap size in Gigabytes (set >= RAM for hibernation).";
    };

    resumeOffset = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = ''
        Physical swap file offset on the filesystem (required for hibernation).

        Commands to find the offset after swapfile is created:
          • ext4 / xfs:
              sudo filefrag -v ''${cfg.path} | awk '$1=="0:" {print substr($4, 1, length($4)-2)}'

          • btrfs:
              sudo btrfs inspect-internal map-swapfile -r ${cfg.path}
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    swapDevices = [
      {
        device = cfg.path;
        size = cfg.sizeGb * 1024;
      }
    ];
  };
}
