{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.maple.system.autoWifi;

  toggleWifi = pkgs.writeShellScript "toggle-wifi" ''
    ethernet_online=0

    for dev in /sys/class/net/*; do
      [ -e "$dev" ] || continue

      # Only inspect physical interfaces (ignores loopback, bridges, Tailscale, Docker, etc.)
      # and exclude Wi-Fi interfaces
      if [ -d "$dev/device" ] && [ ! -d "$dev/wireless" ] && [ ! -d "$dev/phy80211" ]; then
        carrier="$(cat "$dev/carrier" 2>/dev/null || echo 0)"
        if [ "$carrier" = "1" ]; then
          ethernet_online=1
          break
        fi
      fi
    done

    if [ "$ethernet_online" -eq 1 ]; then
      ${pkgs.networkmanager}/bin/nmcli radio wifi off
    else
      ${pkgs.networkmanager}/bin/nmcli radio wifi on
    fi
  '';
in
{
  options.maple.system.autoWifi = {
    enable = lib.mkEnableOption "automatic Wi-Fi toggling based on Ethernet carrier state";
  };

  config = lib.mkIf cfg.enable {
    # Trigger on any network carrier/interface state change (plug, unplug, undock)
    networking.networkmanager.dispatcherScripts = [
      {
        source = toggleWifi;
      }
    ];

    # Apply correct state on boot
    systemd.services.apply-auto-wifi-on-boot = {
      description = "Set Wi-Fi state based on Ethernet carrier at boot";
      after = [ "NetworkManager.service" ];
      wantedBy = [ "NetworkManager.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${toggleWifi}";
      };
    };
  };
}
