{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.maple.apps.rustdesk;
in
{
  options.maple.apps.rustdesk = {
    enable = lib.mkEnableOption "RustDesk (Flatpak version)";
  };

  config = lib.mkIf cfg.enable {
    maple.system.flatpak = {
      enable = true;
      packages = [ "com.rustdesk.RustDesk" ];
    };

    systemd.user.services.rustdesk-config = {
      description = "Ensure custom server settings in RustDesk2.toml";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.python3}/bin/python3 ${./config.py}";
      };
    };
  };
}
