{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.maple.system.android;
in
{
  options.maple.system.android = {
    enable = lib.mkEnableOption "waydroid android emulator";
  };
  config = lib.mkIf cfg.enable {
    virtualisation.waydroid = {
      enable = true;
      package = pkgs.waydroid-nftables;
    };

    networking.firewall.trustedInterfaces = [ "waydroid0" ];

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "maple-waydroid-setup" ''
        set -euo pipefail

        if [ "$(id -u)" -ne 0 ]; then
          echo "Error: setup-waydroid must be run with sudo."
          exit 1
        fi

        echo "-> Stopping active sessions..."
        waydroid session stop 2>/dev/null || true
        systemctl stop waydroid-container 2>/dev/null || true

        echo "-> Initializing Waydroid with GAPPS..."
        waydroid init -s GAPPS -f

        echo "-> Starting container..."
        systemctl start waydroid-container

        echo "-> Installing ARM translation layer (libndk)..."
        nix run --extra-experimental-features "nix-command flakes" github:nix-community/NUR#repos.ataraxiasjel.waydroid-script -- install libndk

        echo "-> Applying changes and restarting container..."
        systemctl restart waydroid-container

        echo "--------------------------------------------------------"
        echo "Setup complete! Next steps:"
        #echo "1. Close this terminal and run as your normal user:"
        echo "waydroid show-full-ui"
        #echo "2. Wait ~1 minute for Android and Google services to boot."
        #echo "3. Open a second terminal and run:"
        #echo "     sudo maple-waydroid-cert"
        #echo "4. Register the printed ID at:"
        #echo "     https://www.google.com/android/uncertified/"
        echo "--------------------------------------------------------"
      '')

      #(pkgs.writeShellScriptBin "maple-waydroid-cert" ''
      #set -euo pipefail
      #if [ "$(id -u)" -ne 0 ]; then
      #  echo "Error: waydroid-cert must be run with sudo."
      #  exit 1
      #fi
      #nix run --extra-experimental-features "nix-command flakes" github:nix-community/NUR#repos.ataraxiasjel.waydroid-script -- certified
      #'')

      (pkgs.writeShellScriptBin "maple-waydroid-wipe" ''
        set -euo pipefail

        if [ "$(id -u)" -ne 0 ]; then
          echo "Error: waydroid-purge must be run with sudo."
          exit 1
        fi

        read -r -p "This will permanently delete all Waydroid images, containers, and app data. Continue? [y/N] " response
        case "$response" in
          [yY][eE][sS]|[yY])
            ;;
          *)
            echo "Purge aborted."
            exit 0
            ;;
        esac

        echo "-> Stopping active sessions and services..."
        waydroid session stop 2>/dev/null || true
        systemctl stop waydroid-container 2>/dev/null || true

        echo "-> Unmounting any lingering filesystem mounts..."
        for mount_point in $(grep waydroid /proc/mounts | awk '{print $2}' | sort -r); do
          umount -l "$mount_point" 2>/dev/null || true
        done

        echo "-> Removing /var/lib/waydroid..."
        rm -rf /var/lib/waydroid

        if [ -n "''${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ]; then
          USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
          echo "-> Removing user data and app desktop shortcuts for $SUDO_USER..."
          rm -rf "$USER_HOME/.local/share/waydroid"
          rm -rf "$USER_HOME/.local/share/applications/"*waydroid*
        fi

        rm -rf /root/.local/share/waydroid

        echo "Waydroid has been completely wiped."
      '')
    ];
  };
}
