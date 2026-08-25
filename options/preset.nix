{ config, lib, ... }:

let
  cfg = config.maple.preset;
in
{
  options.maple.preset = lib.mkOption {
    type = lib.types.nullOr (
      lib.types.enum [
        "tv"
      ]
    );
    default = null;
    description = "Prebuilt machine configuration.";
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg == "tv") {
      maple.system.target = "graphical";
      maple.desktops.gnome.enable = true;
      maple.apps.zattoo.enable = true;

      maple.users.guest = lib.mkDefault "Tv";
      services.displayManager.autoLogin = {
        enable = true;
        user = "guest";
      };
    })
  ];
}
