{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.podman;
in
{
  options.features.podman = {
    enable = lib.mkEnableOption "Podman container engine";

    socket = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable system-wide rootful Docker-compatible socket (/var/run/docker.sock).";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.containers.enable = true;
    virtualisation.containers.registries.search = [ "docker.io" ];

    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true; # Create a `docker` alias for podman
        dockerSocket.enable = cfg.socket; # System-wide rootful socket toggle
        defaultNetwork.settings.dns_enabled = true;
        autoPrune.enable = true;
      };
    };

    virtualisation.oci-containers.backend = "podman";

    environment.systemPackages = with pkgs; [
      podman-compose
    ];

    # Dedicated system user pool for rootful systemd-run container isolation
    users.users.containers = {
      isSystemUser = true;
      group = "containers";
      subUidRanges = [
        {
          startUid = 2147483647;
          count = 2147483648;
        }
      ];
      subGidRanges = [
        {
          startGid = 2147483647;
          count = 2147483648;
        }
      ];
    };
    users.groups.containers = { };
  };
}
