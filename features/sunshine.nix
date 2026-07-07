{
  lib,
  config,
  pkgs,
  ...
}:

{
  options.services.sunshine.cuda = lib.mkEnableOption "CUDA support for Sunshine";

  config = {
    services.sunshine = {
      enable = true;
      cuda = lib.mkDefault false;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };

    #users.users.myuser.extraGroups = [ "uinput" ]; # Give user uinput
    hardware.uinput.enable = true;

    services.sunshine.package = lib.mkIf config.services.sunshine.cuda (
      pkgs.sunshine.override {
        cudaSupport = true;
        cudaPackages = pkgs.cudaPackages;
      }
    );
  };
}
