# Adds support for printing to most printers

{ pkgs, ... }:

{
  # Config app
  environment.systemPackages = with pkgs; [
    system-config-printer
  ];

  # Printing
  services.printing = {
    enable = true;
    browsed.enable = false; # Disable auto adding printers
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
  };
}
