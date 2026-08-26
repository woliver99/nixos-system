{
  config,
  lib,
  ...
}:

let
  cfg = config.maple.apps.gimp;
in
{
  options.maple.apps.gimp = {
    enable = lib.mkEnableOption "GIMP (Flatpak version)";
  };

  config = lib.mkIf cfg.enable {
    maple.system.flatpak = {
      enable = true;
      packages = [ "org.gimp.GIMP" ];
    };
  };
}

