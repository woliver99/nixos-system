# Common config for every system

{ lib, pkgs, ... }:

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

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "macro-paste" ''
      # Retrieve the Wayland clipboard contents immediately
      CLIPBOARD=$(${pkgs.wl-clipboard}/bin/wl-paste --no-newline)

      if [ -z "$CLIPBOARD" ]; then
        echo "Clipboard is empty!" >&2
        exit 1
      fi

      # Wait the requested 2 seconds
      sleep 2

      # Process and type the clipboard contents via a single dotool process
      {
        first=true
        printf '%s\n' "$CLIPBOARD" | while IFS= read -r line || [ -n "$line" ]; do
          if [ "$first" = true ]; then
            first=false
          else
            echo "key enter"
          fi
          printf 'type %s\n' "$line"
        done
      } | ${pkgs.dotool}/bin/dotool
    '')
  ];

  maplenetwork.localCache.enable = lib.mkDefault true;
}
