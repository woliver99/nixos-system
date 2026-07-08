# Adds support for most printers/scanners

{ pkgs, ... }:

{
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
}
