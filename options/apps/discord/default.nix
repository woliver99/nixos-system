{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.maple.apps.discord;
in
{
  options.maple.apps.discord = {
    enable = lib.mkEnableOption "Discord using Vesktop (Flatpak version)";
  };

  config = lib.mkIf cfg.enable {
    maple.system.flatpak = {
      enable = true;
      packages = [ "dev.vencord.Vesktop" ];
    };

    systemd.user.tmpfiles.rules = [
      "L+ %h/.config/autostart/dev.vencord.Vesktop.desktop - - - - ${pkgs.writeText "dev.vencord.Vesktop.desktop" ''
        [Desktop Entry]
        Type=Application
        Name=dev.vencord.Vesktop
        X-XDP-Autostart=dev.vencord.Vesktop
        Exec=flatpak run dev.vencord.Vesktop --enable-speech-dispatcher --start-minimized
        X-Flatpak=dev.vencord.Vesktop
      ''}"
      "C+ %h/.var/app/dev.vencord.Vesktop/config/vesktop/userAssets/tray - - - - ${./icon.png}"
      "C+ %h/.var/app/dev.vencord.Vesktop/config/vesktop/userAssets/trayUnread - - - - ${./icon.png}"
    ];
  };
}
