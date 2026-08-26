{
  config,
  lib,
  ...
}:

let
  cfg = config.maple.system.secureboot;
  hasLuks = config.maple.system.luks.enable or false;
in
{
  options.maple.system.secureboot = {
    enable = lib.mkEnableOption "Enable's secureboot with limeline";
  };

  config = lib.mkIf cfg.enable {
    boot = {
      loader = {
        # Enroll secureboot: sudo sbctl create-keys && sudo sbctl enroll-keys -m && sudo sbctl status
        limine = {
          enable = true;
          secureBoot.enable = lib.mkDefault true;
        };

        # Does not support secureboot
        systemd-boot.enable = false;
        grub.enable = false;
      };

      # Allow hibernate to work if full disk encryption (LUKS) is active
      kernelPatches = lib.optional hasLuks {
        name = "disable-lockdown-for-hibernation";
        patch = null;
        structuredExtraConfig = with lib.kernel; {
          SECURITY_LOCKDOWN_LSM = no;
        };
      };
    };
  };
}
