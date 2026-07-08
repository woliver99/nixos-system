# winapps configured for my laptop, will be made useable on other systems

# sudo nix-channel --add https://github.com/winapps-org/winapps/archive/main.tar.gz winapps && sudo nix-channel --update winapps

{ pkgs, ... }:

let
  winapps-pkg = (import <winapps>).packages."${pkgs.stdenv.hostPlatform.system}".winapps;
  #winapps-launcher = (import winapps-src).packages."${system}".winapps-launcher;
in
{
  environment.systemPackages = with pkgs; [
    winapps-pkg
    #winapps-launcher

    freerdp
    iproute2
    libnotify
    dialog
    jq
    netcat-openbsd
  ];

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  users.users.woliver99.extraGroups = [
    "libvirtd"
    "kvm"
  ];

  environment.sessionVariables = {
    LIBVIRT_DEFAULT_URI = [ "qemu:///system" ];
  };
}
