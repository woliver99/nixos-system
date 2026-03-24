# Installs obs with the pipewire plugin, includes virtual camera support

{ pkgs, ... }:

let
  obs-source-copy = pkgs.qt6Packages.callPackage ../modules/obs-source-copy.nix { };
in
{
  programs.obs-studio = {
    enable = true;

    plugins = with pkgs.obs-studio-plugins; [
      obs-pipewire-audio-capture
      obs-source-copy
      obs-backgroundremoval
    ];

    # Wasted an hour trying to get this to work, no clue why its not working.
    enableVirtualCamera = false;
  };
}
