{ pkgs, ... }:

{
  boot.initrd.systemd.enable = true;

  # Enroll TPM for passwordless boot: sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2 /dev/<data-partition>
  boot.initrd.luks.devices."enc-pv".crypttabExtraOpts = [ "tpm2-device=auto" ];

  # Make tpm2-tools available in the system
  environment.systemPackages = with pkgs; [
    tpm2-tools
    sbctl
  ];

  # Enroll secureboot: sudo sbctl create-keys && sudo sbctl enroll-keys -m && sudo sbctl status
  boot.loader = {
    limine = {
      enable = true;
      secureBoot.enable = true;
    };
    systemd-boot.enable = false; # Does not support secureboot
  };
}
