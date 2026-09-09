{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.maple.patches.laurentian-wifi;
in
{
  options.maple.patches.laurentian-wifi = {
    enable = lib.mkEnableOption "Apply a patch to allow older authentication so the laurentian secure wifi works";
  };

  config = lib.mkIf cfg.enable {
    systemd.services.wpa_supplicant.environment.OPENSSL_CONF = pkgs.writeText "openssl.cnf" ''
      openssl_conf = openssl_init

      [openssl_init]
      ssl_conf = ssl_sect

      [ssl_sect]
      system_default = system_default_sect

      [system_default_sect]
      Options = UnsafeLegacyRenegotiation
      CipherString = Default:@SECLEVEL=0
    '';
  };
}
