{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.maple.system.target;
in
{
  options.maple.system.target = lib.mkOption {
    type = lib.types.enum [
      "headless"
      "graphical"
    ];
    #default = "graphical"; # Force user to pick
    description = "System environment target.";
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg == "headless") {
      maple.profiles.ssh.enable = lib.mkDefault true;
      profiles.proxmox.enable = lib.mkDefault true;
      maplenetwork.colmenaDeploy.enable = lib.mkDefault true;

      features.podman = {
        enable = lib.mkDefault true;
        socket = lib.mkDefault true;
      };
    })
    (lib.mkIf (cfg == "graphical") {
      maple = {
        system = {
          flatpak.enable = lib.mkDefault true;
          printers.enable = lib.mkDefault true;
          vpn.enable = lib.mkDefault true;
        };
        presets.apps.consumer = lib.mkDefault true;
        tools.macro-paste.enable = lib.mkDefault true;
      };

      # Allow execution of appimage files
      programs.appimage = {
        enable = lib.mkDefault true;
        binfmt = lib.mkDefault true;
      };

      environment.systemPackages = with pkgs; [
        ntfs3g # Needed for using gparted on ntfs partitions
        alacritty # Better Terminal
        gparted # Better file partitions
        file-roller # Archive viewer
        nvtopPackages.full # Htop for gpu
      ];
    })
  ];
}
