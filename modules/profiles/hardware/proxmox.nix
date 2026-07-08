# Common config for a standard proxmox virtual machine

{ ... }:

{
  services.qemuGuest.enable = true;

  # Automatically grow the filesystem on boot.
  boot.growPartition = true;
  fileSystems."/".autoResize = true;
}
