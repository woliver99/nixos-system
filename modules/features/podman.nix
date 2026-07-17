{ pkgs, ... }:

{
  virtualisation.containers.enable = true;

  virtualisation.containers.registries.search = [ "docker.io" ];

  virtualisation = {
    podman = {
      enable = true;

      dockerCompat = true; # Create a `docker` alias for podman, to use it as a drop-in replacement

      defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.

      autoPrune.enable = true; # Periodically clean up stopped containers & dangling images
    };
  };

  virtualisation.oci-containers.backend = "podman";

  environment.systemPackages = with pkgs; [
    podman-compose
  ];

  # For rootful systemd-run Podman containers, '--userns=auto' requires a system user named 'containers' with a large pool of host UIDs allocated to it.
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
}
