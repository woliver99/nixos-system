{ config, lib, ... }:

let
  cfg = config.maple.users.wselena99;
in
{
  options.maple.users.wselena99 = {
    enable = lib.mkEnableOption "Selena's user";
  };

  config = lib.mkIf cfg.enable {
    maple.users.admins.wselena99.displayName = "Selena Wuthrich-Giroux";
  };
}
