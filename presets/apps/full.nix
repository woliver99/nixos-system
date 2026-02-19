# This configuration contains apps all apps needed for a complete desktop experience

{ pkgs, ... }:

{
  imports = [
    ./essentials.nix
  ];

  # Install Firefox (Required for digital certificates in libreoffice)
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    nvtopPackages.full # View GPU usage
    ntfs3g # Needed for using gparted on ntfs partitions

    # -- GUI --
    alacritty # Better Terminal

    gparted # Better file partitions
    localsend # Send files locally
    file-roller # Archive viewer

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

  networking.firewall = {
    allowedTCPPorts = [
      53317 # Localsend
    ];
    allowedUDPPorts = [
      53317 # Localsend
    ];
  };
}
