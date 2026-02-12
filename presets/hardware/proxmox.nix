# Common config for a standard proxmox virtual machine

{ ... }:

{
  imports = [
    ../../modules/virtual-machine.nix
    ../../modules/server.nix
  ];

  # Automatically grow the filesystem on boot.
  boot.growPartition = true;
  fileSystems."/".autoResize = true;
}
