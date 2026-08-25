{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.maple.apps.obs;
  obs-source-copy = pkgs.qt6Packages.callPackage ./source-copy.nix { };
in
{
  options.maple.apps.obs = {
    enable = lib.mkEnableOption "OBS with few plugins";
  };

  config = lib.mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;

      plugins = with pkgs.obs-studio-plugins; [
        obs-pipewire-audio-capture
        obs-source-copy
        obs-backgroundremoval
      ];

      # Wasted an hour trying to get this to work, no clue why its not working.
      enableVirtualCamera = false;
    };
  };
}
