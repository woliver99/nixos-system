{ config, lib, ... }:
let
  cfg = config.maple.system.hibernate;
  swapCfg = config.maple.system.swap;
  # Automatically resolve root filesystem disk from hardware-configuration.nix
  rootDevice = config.fileSystems."/".device or null;
in
{
  options.maple.system.hibernate = {
    enable = lib.mkEnableOption "suspend-then-hibernate support";

    resumeDevice = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Disk device UUID containing swap. Automatically inferred from root filesystem if null.";
    };

    delay = lib.mkOption {
      type = lib.types.str;
      default = "1m";
      description = "Delay before transitioning from suspend to hibernate (e.g. 1m, 30m, 2h).";
    };

    lidSwitch = lib.mkOption {
      type = lib.types.enum [
        "suspend-then-hibernate"
        "suspend"
        "hibernate"
        "ignore"
        "lock"
        "poweroff"
      ];
      default = "suspend-then-hibernate";
      description = "Action when closing the laptop lid.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Automatically turn on swap
    maple.system.swap.enable = lib.mkDefault true;

    powerManagement.enable = true;

    # Auto-resolve resumeDevice if not explicitly overridden
    boot.resumeDevice = lib.mkDefault (
      if cfg.resumeDevice != null then cfg.resumeDevice else rootDevice
    );

    boot.kernelParams = [
      "mem_sleep_default=deep"
      "secretmem.enable=0"
    ]
    ++ lib.optional (config.boot.resumeDevice != null) "resume=${config.boot.resumeDevice}"
    ++ lib.optional (swapCfg.resumeOffset != null) "resume_offset=${toString swapCfg.resumeOffset}";

    services.logind.settings.Login.HandleLidSwitch = cfg.lidSwitch;

    systemd.sleep.settings.Sleep = {
      HibernateDelaySec = cfg.delay;
      SuspendState = "mem";
    };

    assertions = [
      {
        assertion = swapCfg.resumeOffset != null;
        message = ''
          `maple.system.hibernate` is enabled, but `maple.system.swap.resumeOffset` is not set!
          Without the swap file offset, the system will fail to resume from hibernation.

          Find your offset:
            • ext4: sudo filefrag -v /var/lib/swapfile | awk '$1=="0:" {print substr($4, 1, length($4)-2)}'
            • btrfs: sudo btrfs inspect-internal map-swapfile -r /var/lib/swapfile
        '';
      }
    ];
  };
}
