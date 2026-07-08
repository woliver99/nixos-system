# This configuration contains apps all apps needed for a complete developer desktop experience

{ pkgs, ... }:

{
  imports = [
    ./full.nix
  ];


  environment.systemPackages = with pkgs; [
    gh
    filezilla
    android-tools

    # IDEs
    android-studio
    jetbrains.idea-oss
    arduino-ide
    vscode

    #unstable.flutter
    #unstable.antigravity-fhs

    # Python
    python313
    python313Packages.pyserial
  ];

  # For PlatformIO
  services.udev.packages = with pkgs; [ platformio-core.udev ];
}
