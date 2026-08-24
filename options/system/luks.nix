{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.maple.system.luks;
in
{
  options.maple.system.luks = {
    enable = lib.mkEnableOption "Luks with TPM support for passwordless boot";
  };

  config = lib.mkIf cfg.enable {
    boot.initrd.systemd.enable = true;

    # Enroll TPM for passwordless boot: sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2 /dev/<data-partition>
    boot.initrd.luks.devices."enc-pv".crypttabExtraOpts = [ "tpm2-device=auto" ];

    # Make tpm2-tools available in the system
    environment.systemPackages = with pkgs; [
      tpm2-tools
      sbctl
    ];
  };
}
