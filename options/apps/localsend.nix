{ config, lib, ... }:

let
  cfg = config.maple.apps.localsend;
in
{
  options.maple.apps.localsend = {
    enable = lib.mkEnableOption "Localsend (Flatpak version)";
  };

  config = lib.mkIf cfg.enable {
    maple.system.flatpak = {
      enable = true;
      packages = [ "org.localsend.localsend_app" ];
    };

    networking.firewall = {
      allowedTCPPorts = [ 53317 ];
      allowedUDPPorts = [ 53317 ];
    };
  };
}
