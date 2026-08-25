{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.maple.system.flatpak;
in
{
  options.maple.system.flatpak = {
    enable = lib.mkEnableOption "Flatpak with Flathub repository.";

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of Flatpak Application IDs to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.flatpak.enable = true;

    systemd.services.flatpak-managed-install = {
      description = "Flatpak subsystem and management.";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      path = [ pkgs.flatpak ];
      script = ''
        # Flathub repo
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

        # Install declared packages
        ${lib.concatMapStringsSep "\n" (pkg: ''
          flatpak install --noninteractive -y flathub ${pkg}
        '') cfg.packages}
      '';
    };
  };
}
