{ pkgs, ... }:

{
  virtualisation.containers.enable = true;

  virtualisation.containers.registries.search = [ "docker.io" ];

  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  virtualisation.oci-containers.backend = "podman";

  environment.systemPackages = with pkgs; [
    podman-compose
  ];
}
