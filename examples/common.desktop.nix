{ ... }:

{
  maple = {
    system = {
      target = "graphical";
      hardware = {
        enable = true;
        #ramGb = 32; # System ram size for system recommendations
        #storageType = "ssd"; # Boot storage storage type for system recommendations
      };

      # Laptop settings
      #hibernate.enable = true; # Swap needed
      #swap.resumeOffset = 12228360; # Needed for hibernate, check description
      #powerProfiles.enable = true; # Auto preformance/power-saving mode when connected to power
      #autoWifi.enable = true; # Disabled wifi when ethernet connects

      #drawingTablet.enable = true;
    };

    users.woliver99 = {
      enable = true;
      hidden = false;
    };

    desktops.gnome = {
      enable = true;
      #remoteDesktop = true;
    };

    presets.apps = {
      #gamer = true;
    };

    apps = {
      #bitwarden.enable = true;
      #zattoo.enable = true;
    };
  };
}
