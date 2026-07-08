# My nixvim config with wl-clipboard

{ pkgs, ... }:

{
  imports = [
    ./common.nix
  ];

  programs.nixvim.clipboard.providers.wl-copy.enable = true;

  environment.systemPackages = with pkgs; [
    wl-clipboard
  ];

  # Allows "sudo nvim" to work properly, wouldnt recommend in server environments due to potential security issues.
  security.sudo.extraConfig = ''
    Defaults env_keep += "WAYLAND_DISPLAY XDG_RUNTIME_DIR"
  '';
}
