{ config, lib, ... }:

{
  options.mySystem.proxmox.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable Proxmox VM integrations (QEMU guest agent and disk auto-resize).";
  };

  config = lib.mkIf config.mySystem.proxmox.enable {
    services.qemuGuest.enable = true;

    boot.growPartition = true;
    fileSystems."/".autoResize = true;
  };
}
