{ config, lib, ... }:
let
  cfg = config.maple.system.swap.compression;
  diskSwapEnabled = config.maple.system.swap.enable;

  effectiveType =
    if !cfg.enable then
      "none"
    else if cfg.type != "auto" then
      cfg.type
    else if diskSwapEnabled then
      "zswap"
    else
      "zram";

  defaultPercent = if effectiveType == "zswap" then 25 else 50;
  targetPercent = if cfg.percent != null then cfg.percent else defaultPercent;
in
{
  options.maple.system.swap.compression = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable in-memory swap compression (zswap or zram).";
    };

    type = lib.mkOption {
      type = lib.types.enum [
        "auto"
        "zswap"
        "zram"
        "none"
      ];
      default = "auto";
      description = ''
        Compression backend. "auto" selects zswap if disk swap is enabled,
        and zram if disk swap is disabled.
      '';
    };

    percent = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = "Memory pool or device limit percentage (default: 25% for zswap, 50% for zram).";
    };

    algorithm = lib.mkOption {
      type = lib.types.str;
      default = "zstd";
      description = "Compression algorithm (e.g. zstd, lz4).";
    };
  };

  config = lib.mkMerge [
    # Backed by physical swapfile -> zswap
    (lib.mkIf (effectiveType == "zswap") {
      boot.zswap = {
        enable = true;
        compressor = cfg.algorithm;
        maxPoolPercent = targetPercent;
        shrinkerEnabled = true;
      };
    })

    # No disk swap -> zram
    (lib.mkIf (effectiveType == "zram") {
      zramSwap = {
        enable = true;
        algorithm = cfg.algorithm;
        memoryPercent = targetPercent;
      };
      boot.kernel.sysctl = {
        "vm.swappiness" = lib.mkDefault 180;
        "vm.page-cluster" = lib.mkDefault 0;
      };
    })
  ];
}
