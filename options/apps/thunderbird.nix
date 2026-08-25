{
  config,
  lib,
  ...
}:

let
  cfg = config.maple.apps.thunderbird;
in
{
  options.maple.apps.thunderbird = {
    enable = lib.mkEnableOption "Thunderbird (Flatpak version)";
  };

  config = lib.mkIf cfg.enable {
    maple.system.flatpak = {
      enable = true;
      packages = [ "org.mozilla.thunderbird" ];
    };
  };
}
