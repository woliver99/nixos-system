# Common config for all virtual machines

{ ... }:

{
  # Enable the QEMU Guest Agent for proper communication with Proxmox.
  services.qemuGuest.enable = true;
}
