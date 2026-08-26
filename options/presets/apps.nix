{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.maple.presets.apps;
in
{
  options.maple.presets.apps = {
    consumer = lib.mkEnableOption "everyday consumer applications";
    gamer = lib.mkEnableOption "gaming apps and discord";
    developer = lib.mkEnableOption "developer tools and IDEs";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.consumer {
      # Required for digital certificates in libreoffice
      programs.firefox.enable = lib.mkDefault true;

      maple.apps = {
        localsend.enable = lib.mkDefault true;
        thunderbird.enable = lib.mkDefault true;
        gimp.enable = lib.mkDefault true;
      };

      environment.systemPackages = with pkgs; [
        vlc # Music/Audio
        brave # Browser

        xournalpp # PDF editor
        pdfarranger # Arrange PDFs

        soundconverter # Convert sounds
        switcheroo # Image conversion
        losslesscut-bin # Trim video without rencoding

        # LibreOffice
        libreoffice-still
        hunspell
        hunspellDicts.en_CA
      ];
    })

    (lib.mkIf cfg.developer {
      maple.apps = {
        steam.enable = lib.mkDefault true;
        discord.enable = lib.mkDefault true;
        easyeffects.enable = lib.mkDefault true; # For noise suppression
        obs.enable = lib.mkDefault true; # For recording your gameplay
      };
    })

    (lib.mkIf cfg.developer {
      maple.presets.apps.consumer = lib.mkDefault true;

      environment.systemPackages = with pkgs; [
        gh
        filezilla
        android-tools

        # IDEs
        android-studio
        jetbrains.idea
        arduino-ide
        vscode
      ];

      # For PlatformIO
      services.udev.packages = with pkgs; [ platformio-core.udev ];
    })
  ];
}
