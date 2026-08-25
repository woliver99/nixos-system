{ config, lib, ... }:

let
  cfg = config.maple.system.drawingTablet;
in
{
  options.maple.system.drawingTablet = {
    enable = lib.mkEnableOption "OpenTabletDriver and uinput drawing tablet support";
  };

  config = lib.mkIf cfg.enable {
    # Enable OpenTabletDriver
    hardware.opentabletdriver.enable = true;

    # Required by OpenTabletDriver
    hardware.uinput.enable = true;
    boot.kernelModules = [ "uinput" ];
  };
}
