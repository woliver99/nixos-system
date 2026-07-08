# This file adds support for most vpns

{ pkgs, ... }:

{
  networking = {
    networkmanager.plugins = with pkgs; [
      networkmanager-openvpn
      networkmanager-l2tp
    ];

    firewall = {
      allowedUDPPorts = [
        51821 # Wireguard
      ];

      # Allow WireGuard traffic through the reverse path filter
      extraCommands = ''
        ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 51821 -j RETURN
        ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 51821 -j RETURN
      '';
      extraStopCommands = ''
        ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 51821 -j RETURN || true
        ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 51821 -j RETURN || true
      '';
    };
  };
}
