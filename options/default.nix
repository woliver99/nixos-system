{ ... }:

{
  imports = [
    ./hide-users.nix
    ./proxmox.nix
    ./cache.nix
    ./remote-build.nix
    ./colmena-deploy.nix
    ./maintenance.nix
    ./podman.nix

    ./profiles/flatpak.nix
    ./profiles/bitwarden.nix

    ./system/luks.nix
    ./system/secureboot.nix
    ./system/fingerprint.nix
    ./system/impermanence.nix
  ];
}
