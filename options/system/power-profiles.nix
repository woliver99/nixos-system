{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.maple.system.powerProfiles;

  setPowerProfile = pkgs.writeShellScript "set-power-profile" ''
    ac_online=0
    for ps in /sys/class/power_supply/*; do
      if [ -f "$ps/type" ] && [ "$(cat "$ps/type")" = "Mains" ] && [ -f "$ps/online" ]; then
        if [ "$(cat "$ps/online")" = "1" ]; then
          ac_online=1
          break
        fi
      fi
    done

    if [ "$ac_online" -eq 1 ]; then
      ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set ${cfg.onAC}
    else
      ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set ${cfg.onBattery}
    fi
  '';
in
{
  options.maple.system.powerProfiles = {
    enable = lib.mkEnableOption "power-profiles-daemon with automatic AC/battery profile switching";

    onAC = lib.mkOption {
      type = lib.types.enum [
        "performance"
        "balanced"
        "power-saver"
      ];
      default = "performance";
      description = "Power profile when plugged into AC power.";
    };

    onBattery = lib.mkOption {
      type = lib.types.enum [
        "performance"
        "balanced"
        "power-saver"
      ];
      default = "power-saver";
      description = "Power profile when operating on battery power.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.power-profiles-daemon.enable = true;

    # Trigger profile switch on AC plug/unplug events
    services.udev.extraRules = ''
      ACTION=="change", SUBSYSTEM=="power_supply", RUN+="${setPowerProfile}"
    '';

    # Set profile on boot based on AC state
    systemd.services.apply-power-profile-on-boot = {
      description = "Set power profile based on initial AC state at boot";
      after = [ "power-profiles-daemon.service" ];
      wantedBy = [ "power-profiles-daemon.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${setPowerProfile}";
      };
    };
  };
}
