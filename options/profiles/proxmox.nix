{ config, lib, ... }:

let
  cfg = config.maple.profiles.proxmox;
in
{
  options.maple.profiles.proxmox = {
    enable = lib.mkEnableOption "Proxmox VM integrations (QEMU guest agent).";
  };

  config = lib.mkIf cfg.enable {
    services.qemuGuest.enable = true;
    services.fstrim.interval = "daily";
  };
}
