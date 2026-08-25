{
  config,
  lib,
  ...
}:

let
  cfg = config.maple.apps.easyeffects;
in
{
  options.maple.apps.easyeffects = {
    enable = lib.mkEnableOption "Easy Effects (Flatpak version)";
  };

  config = lib.mkIf cfg.enable {
    maple.system.flatpak = {
      enable = true;
      packages = [ "com.github.wwmm.easyeffects" ];
    };
  };
}

