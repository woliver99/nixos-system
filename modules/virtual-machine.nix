# Common config for all virtual machines

{ ... }:

{
  # Automatically grow the filesystem on boot.
  boot.growPartition = true;
  fileSystems."/".autoResize = true;

  # Enable the QEMU Guest Agent for proper communication with Proxmox.
  services.qemuGuest.enable = true;
}
