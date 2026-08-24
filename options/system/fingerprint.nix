{
  config,
  lib,
  ...
}:

let
  cfg = config.maple.system.fingerprint;
in
{
  options.maple.system.fingerprint = {
    enable = lib.mkEnableOption "Enable fprintd";
  };

  config = lib.mkIf cfg.enable {
    # Enroll with: fprintd-enroll
    # Do multiple with: fprintd-enroll -f right-thumb
    services.fprintd.enable = true;
  };
}
