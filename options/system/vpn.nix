{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.maple.system.vpn;
in
{
  options.maple.system.vpn = {
    enable = lib.mkEnableOption "VPN support (NetworkManager plugins and WireGuard firewall routing)";

    wireguardPorts = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [ 51820 ];
      description = "List of UDP ports used by WireGuard interfaces.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      networkmanager.plugins = with pkgs; [
        networkmanager-openvpn
        networkmanager-l2tp
      ];

      firewall = {
        # Open the listed ports
        allowedUDPPorts = cfg.wireguardPorts;

        # Dynamically generate rpfilter bypass rules for each port
        extraCommands = lib.concatMapStrings (port: ''
          ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport ${toString port} -j RETURN
          ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport ${toString port} -j RETURN
        '') cfg.wireguardPorts;

        extraStopCommands = lib.concatMapStrings (port: ''
          ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport ${toString port} -j RETURN || true
          ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport ${toString port} -j RETURN || true
        '') cfg.wireguardPorts;
      };
    };
  };
}
