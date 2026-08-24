{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.maple.put-option-here;
in
{
  options.maple.put-option-here = {
    enable = lib.mkEnableOption "put-description-here";
  };

  config = lib.mkIf cfg.enable {
    ## Config goes here
  };
}
