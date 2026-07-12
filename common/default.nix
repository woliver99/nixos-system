# Common config for every system

{ lib, ... }:

{
  imports = [
    ../options # Custom nix configuration options for easier customizations
  ];

  time.timeZone = lib.mkDefault "America/Toronto"; # Time zone
  i18n.defaultLocale = lib.mkDefault "en_CA.UTF-8"; # Internationalisation properties
  nixpkgs.config.allowUnfree = true; # Allow proprietary software to be installed

  # Keymap
  services.xserver.xkb = {
    layout = lib.mkDefault "us";
    variant = lib.mkDefault "";
  };

  programs.bash.shellAliases = {
    editconfig = "cd /etc/nixos/";
    explorer = "(xdg-open . > /dev/null 2>&1 &)";
    sys-update = "editconfig &&  sudo bash ./nixos-system/scripts/update.sh";
    sys-dryupdate = "editconfig && sudo bash ./nixos-system/scripts/update.sh --dry-run";
  };

  maplenetwork.localCache.enable = lib.mkDefault true;
}
