{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.maple.system.printers;
in
{
  options.maple.system.printers = {
    enable = lib.mkEnableOption "support for most printers/scanners";
  };

  config = lib.mkIf cfg.enable {
    # Config app
    environment.systemPackages = with pkgs; [
      system-config-printer
    ];

    # Printing
    services.printing = {
      enable = true;
      browsed.enable = true;
    };

    # Auto discovery
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      # GNOME auto adds printers for some reason? (https://gitlab.gnome.org/GNOME/gnome-control-center/-/issues/1001)
    };

    # Scanning
    hardware.sane = {
      enable = true;
      extraBackends = [
        pkgs.sane-airscan # Universal
      ];
      disabledDefaultBackends = [ "escl" ]; # Disable default universal driver
    };
  };
}
