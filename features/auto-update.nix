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
    dates = lib.mkDefault "Sat *-*-* 04:30:00";
  };

  nix.optimise = {
    automatic = lib.mkDefault true;
    dates = [ "Sat *-*-1..7 04:45:00" ]; # First Saturday of the month
  };

  systemd.services.nixos-upgrade.serviceConfig = {
    Nice = 19;
    IOSchedulingClass = "idle";
  };

  systemd.services.nix-gc.serviceConfig = {
    Nice = 19;
    IOSchedulingClass = "idle";
  };

  systemd.services.nix-optimise.serviceConfig = {
    Nice = 19;
    IOSchedulingClass = "idle";
  };
}
