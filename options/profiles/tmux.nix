{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.maple.profiles.tmux;
in
{
  options.maple.profiles.tmux = {
    enable = lib.mkEnableOption "Tmux with sane defaults";
  };

  config = lib.mkIf cfg.enable {
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
  };
}
