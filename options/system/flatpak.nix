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
      path = [
        pkgs.flatpak
        pkgs.curl
      ];

      script = ''
        echo "Waiting for internet connection to Flathub..."
        connected=0
        for i in $(seq 1 15); do
          if curl -s --head --fail --connect-timeout 2 https://dl.flathub.org/repo/flathub.flatpakrepo >/dev/null 2>&1; then
            connected=1
            break
          fi
          sleep 2
        done

        if [ "$connected" -eq 0 ]; then
          echo "Network unavailable after timeout; skipping Flatpak installation for now."
          exit 0
        fi

        # Flathub repo
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

        # Install declared packages
        ${lib.concatMapStringsSep "\n" (pkg: ''
          flatpak install --noninteractive -y flathub ${pkg}
        '') cfg.packages}
      '';
    };
  };
}
