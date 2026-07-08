{ pkgs, ... }:

{
  # 1. Enable the Docker background daemon
  virtualisation.docker.enable = true;

  # 2. Tell NixOS to use Docker for declarative containers
  virtualisation.oci-containers.backend = "docker";

  # 3. Add the official Docker Compose package
  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  # 4. Grant your user access to the Docker daemon without needing 'sudo'
  users.users.woliver99.extraGroups = [ "docker" ];
}
