{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.maple.desktops.gnome;
in
{
  options.maple.desktops.gnome = {
    enable = lib.mkEnableOption "GNOME Desktop Environment";
    remoteDesktop = lib.mkEnableOption "GNOME Remote Desktop (RDP) and firewall rules";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # Base GNOME configuration
      {
        maple.system.target = "graphical";
        services.displayManager.gdm.enable = true;
        services.desktopManager.gnome.enable = true;

        # Enable GNOME networking
        networking.networkmanager.enable = true;

        # Exclude GNOME apps
        environment.gnome.excludePackages = [
          pkgs.gnome-console # Use Alacritty instead
        ];

        environment.systemPackages = with pkgs; [
          alacritty # Better Terminal

          # Fake gnome-terminal to trick GNOME into using Alacritty
          (writeShellScriptBin "gnome-terminal" ''
            args=()
            for arg in "$@"; do
              if [ "$arg" == "--" ]; then
                args+=("-e")
              else
                args+=("$arg")
              fi
            done
            exec ${alacritty}/bin/alacritty "''${args[@]}"
          '')

          # GNOME extensions (enable them with the extensions app)
          gnomeExtensions.appindicator
          gnomeExtensions.gsconnect
          gnomeExtensions.color-picker

          # copyous patch
          (gnomeExtensions.copyous.overrideAttrs (old: {
            buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.libgda5 ];
            preInstall = ''
              sed -i "1i import GIRepository from 'gi://GIRepository';\nGIRepository.Repository.dup_default().prepend_search_path('${pkgs.libgda5}/lib/girepository-1.0');\nGIRepository.Repository.dup_default().prepend_search_path('${pkgs.gsound}/lib/girepository-1.0');\n" lib/preferences/dependencies/dependencies.js
              sed -i "1i import GIRepository from 'gi://GIRepository';\nGIRepository.Repository.dup_default().prepend_search_path('${pkgs.libgda5}/lib/girepository-1.0');\n" lib/database/entryTracker.js
            '';
          }))

        ];

        # Extension to add "open in console" for alacritty
        programs.nautilus-open-any-terminal = {
          enable = true;
          terminal = "alacritty";
        };

        networking.firewall = {
          allowedTCPPortRanges = [
            {
              from = 1714;
              to = 1764;
            } # GSConnect
          ];

          allowedUDPPortRanges = [
            {
              from = 1714;
              to = 1764;
            } # GSConnect
          ];
        };

        programs.dconf = {
          enable = true;
          profiles = {
            # Settings for the Login Screen (GDM)
            gdm.databases = [
              {
                settings = {
                  "org/gnome/desktop/peripherals/mouse" = {
                    accel-profile = "flat";
                  };
                };
              }
            ];

            # Settings for User Sessions (System-wide defaults for all users)
            user.databases = [
              {
                settings = {
                  "org/gnome/desktop/interface" = {
                    enable-hot-corners = false;
                  };

                  "org/gnome/desktop/wm/preferences" = {
                    button-layout = ":minimize,maximize,close"; # Add minimize maximize and close to windows
                  };

                  "org/gnome/settings-daemon/plugins/media-keys" = {
                    home = [ "<Super>e" ]; # Super+E for Nautilus
                  };

                  "org/gnome/shell/keybindings" = {
                    show-screenshot-ui = [ "<Shift><Super>s" ]; # Shift+Super+S for screenshot
                    toggle-message-tray = lib.gvariant.mkEmptyArray lib.gvariant.type.string; # Unbind Super+V so it can be used in copyous
                  };
                };
              }
            ];
          };
        };

        fonts = {
          # Nerdfonts are repackaged fonts with extra icons
          packages = with pkgs; [ nerd-fonts.adwaita-mono ];
          fontconfig.defaultFonts.monospace = [ "AdwaitaMono Nerd Font Mono" ];
        };

        # Enable sound with pipewire.
        services.pulseaudio.enable = false;
        security.rtkit.enable = true;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
        };
      }

      # Remote Desktop
      (lib.mkIf cfg.remoteDesktop {
        # Enable the GNOME RDP components
        services.gnome.gnome-remote-desktop.enable = true;

        # Ensure the service starts automatically at boot so the settings panel appears
        systemd.services.gnome-remote-desktop = {
          wantedBy = [ "graphical.target" ];
        };

        networking.firewall = {
          allowedTCPPorts = [
            3389 # Start Virtual Session
            3390 # Connect To Live Session
          ];
          allowedUDPPorts = [
            3389 # Start Virtual Session
            3390 # Connect To Live Session
          ];
        };
      })
    ]
  );
}
