# Enables the Gnome desktop environment

{ pkgs, lib, ... }:

{
  # Currently copyous is not in the nix repo but will be added soon: https://github.com/NixOS/nixpkgs/pull/469919
  nixpkgs.overlays = [
    (final: prev: {
      gnomeExtensions = prev.gnomeExtensions // {
        copyous = prev.callPackage ../../modules/gnome-extension-copyous.nix { };
      };
    })
  ];

  # Enable the GNOME Desktop Environment.
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
    gnomeExtensions.copyous
    gnomeExtensions.appindicator
    gnomeExtensions.gsconnect
    gnomeExtensions.color-picker
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

  programs.dconf.profiles = {
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
