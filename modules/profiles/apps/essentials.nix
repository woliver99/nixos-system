# This configuration contains only essential apps that every system should have

{ pkgs, lib, ... }:

{
  programs.direnv.enable = true;

  programs.tmux = {
    enable = true;
    shortcut = lib.mkDefault "b";
    aggressiveResize = true;
    baseIndex = 1;
    newSession = true;
    escapeTime = 0;
    clock24 = true;
    historyLimit = 50000;
    terminal = "tmux-256color"; # screen-256color was broken with htop

    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
    ];

    extraConfig = ''
      # Enable clipboard (OSC 52 Support)
      set -s set-clipboard on

      # Fix scrolling
      set -g mouse on
    '';
  };

  programs.git = {
    enable = true;
    config.init.defaultBranch = "main";
  };
  # Trust Github for ssh 
  programs.ssh.knownHosts = {
    "github.com" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };
  };

  environment.systemPackages = with pkgs; [
    htop

    wget

    zip
    unzip
  ];

}
