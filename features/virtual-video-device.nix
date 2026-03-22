{ config, ... }:

{
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];

  boot.kernelModules = [
    "v4l2loopback"
  ];

  boot.extraModprobeConfig = ''
    options v4l2loopback video_nr=9 exclusive_caps=1 keep_format=1 card_label="Virtual Camera"
  '';
}
