{
  config,
  lib,
  pkgs,
  ...
}:

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

    environment.systemPackages = [
      (pkgs.writeShellApplication {
        name = "maple-swap-flush";
        runtimeInputs = [
          pkgs.util-linux
          pkgs.procps
          pkgs.gawk
          pkgs.coreutils
        ];
        text = ''
          if [ "$(id -u)" -ne 0 ]; then
            echo "Error: maple-swap-flush must be run as root (use sudo)." >&2
            exit 1
          fi

          mem_avail=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
          swap_used=$(awk '/SwapTotal/ {total=$2} /SwapFree/ {free=$2} END {print total - free}' /proc/meminfo)

          if [ "$swap_used" -le 0 ]; then
            echo "Swap is already empty. Nothing to flush."
            exit 0
          fi

          # Safety check: Prevent OOM crash if swap > available RAM
          if [ "$mem_avail" -le "$swap_used" ]; then
            echo "Error: Not enough available RAM to safely flush swap!" >&2
            echo "Required:  $((swap_used / 1024)) MiB" >&2
            echo "Available: $((mem_avail / 1024)) MiB" >&2
            exit 1
          fi

          echo "Flushing $((swap_used / 1024)) MiB from ${cfg.path} back to RAM..."
          swapoff "${cfg.path}"
          swapon "${cfg.path}"
          echo "Done! Swap space on ${cfg.path} has been cleared."
        '';
      })
    ];
  };
}
