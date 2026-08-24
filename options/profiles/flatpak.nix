{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.maple.profiles.flatpak;
in
{
  options.maple.profiles.flatpak = {
    enable = lib.mkEnableOption "Flatpak with Flathub repository set up";
  };

  config = lib.mkIf cfg.enable {
    services.flatpak.enable = true;
    systemd.services.flatpak-repo = {
      description = "Installs the default Flatpak repo";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      path = [ pkgs.flatpak ];
      script = ''
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      '';
    };
  };
}
