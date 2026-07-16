{ pkgs, ... }:

{
  imports = [
    # -- Common --
    ./default.nix # Common config for every system
  ];

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
}
