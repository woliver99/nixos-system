{ config, lib, ... }:
let
  cfg = config.maple.system.hardware;
  hibernateEnabled = config.maple.system.hibernate.enable or false;

  isSolidState = cfg.storageType == "ssd";
  isFlashOrHdd = cfg.storageType == "hdd" || cfg.storageType == "flash";

  recommendedSwapGb =
    if hibernateEnabled then
      # 1:1 match up to 32 GB; compress ratio allows scaling down for huge RAM pools
      if cfg.ramGb > 32 then (32 + (cfg.ramGb - 32) / 2) else cfg.ramGb
    else if isSolidState then
      (if cfg.ramGb <= 8 then 2 else 4)
    else
      null;

  recommendedCompressionPercent =
    if isFlashOrHdd then
      100 # No disk swap: maximize zram virtual address space
    else if cfg.ramGb <= 8 then
      35 # Constrained RAM: keep pages in RAM longer before hitting SSD
    else if cfg.ramGb <= 32 then
      25 # 16-32 GB sweet spot: avoids excessive CPU overhead and cache eviction
    else
      20; # 64 GB+: 20% pool is already massive (12.8 GB+ physical RAM)
in
{
  options.maple.system.hardware = {
    enable = lib.mkEnableOption "automatic system tuning based on hardware specifications";

    ramGb = lib.mkOption {
      type = lib.types.int;
      example = 16;
      description = "Total physical system RAM in gigabytes (required).";
    };

    storageType = lib.mkOption {
      type = lib.types.enum [
        "ssd"
        "hdd"
        "flash"
      ];
      example = "ssd";
      description = "Underlying root drive technology (required).";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = hibernateEnabled -> isSolidState;
        message = ''
          `maple.system.hibernate` is enabled, but `maple.system.hardware.storageType` is '${cfg.storageType}'.
          Hibernating to mechanical disks or dumb flash memory causes severe wear and I/O lockups.
        '';
      }
    ];

    maple.system.swap = {
      enable = lib.mkDefault (isSolidState && recommendedSwapGb != null);
      sizeGb = lib.mkIf (recommendedSwapGb != null) (lib.mkDefault recommendedSwapGb);
      compression.percent = lib.mkDefault recommendedCompressionPercent;
    };
  };
}
