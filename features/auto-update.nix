{ lib, ... }:

{
  system.autoUpgrade = {
    enable = lib.mkDefault true;
    operation = lib.mkDefault "boot";
    allowReboot = lib.mkDefault false;
    dates = lib.mkDefault "Sat *-*-* 02:00:00";

    # 2:00 AM to 4:00 AM
    randomizedDelaySec = lib.mkDefault "2h";
  };

  nix.gc = {
    automatic = lib.mkDefault true;
    options = lib.mkDefault "--delete-older-than 14d";
    dates = lib.mkDefault "Sun *-*-* 02:00:00";
  };

  # This "hardlinks" identical files in the nix store to save massive amounts of space.
  nix.settings.auto-optimise-store = lib.mkDefault true;

  systemd.timers.nix-gc.timerConfig = {
    RandomizedDelaySec = lib.mkForce "2h";
    AccuracySec = lib.mkForce "1us";
  };
  systemd.services.nix-gc.serviceConfig = {
    Nice = 19;
    IOSchedulingClass = "idle";
  };
}
