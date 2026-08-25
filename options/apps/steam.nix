{
  config,
  lib,
  ...
}:

let
  cfg = config.maple.apps.steam;
in
{
  options.maple.apps.steam = {
    enable = lib.mkEnableOption "Steam ready for gaming";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };
  };
}
