{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.maple.system.fingerprint;

  sys-fingerprint = pkgs.writeShellApplication {
    name = "sys-fingerprint";
    runtimeInputs = with pkgs; [ fprintd ];
    text = ''
      echo "=== Biometric Fingerprint Manager ==="
      echo "1) List enrolled fingerprints"
      echo "2) Enroll / Overwrite a finger"
      echo "3) Delete a finger"
      echo "4) Test / Verify sensor"
      read -r -p "Select an option [1-4]: " opt

      case "$opt" in
        1) fprintd-list "$USER" ;;
        2)
          read -r -p "Finger name (e.g., right-thumb, right-index-finger): " finger
          fprintd-enroll "$USER" -f "$finger"
          ;;
        3)
          read -r -p "Finger to delete: " finger
          fprintd-delete "$USER" -f "$finger"
          ;;
        4) fprintd-verify "$USER" ;;
        *) echo "Invalid option." ;;
      esac
    '';
  };
in
{
  options.maple.system.fingerprint = {
    enable = lib.mkEnableOption "Enable fprintd";
  };

  config = lib.mkIf cfg.enable {
    services.fprintd.enable = true;
    environment.systemPackages = [ sys-fingerprint ];
  };
}
