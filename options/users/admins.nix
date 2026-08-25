{ config, lib, ... }:

{
  options.maple.users.admins = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }: {
          options = {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether to enable this admin account.";
            };
            displayName = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = "Display name of the admin account.";
            };
            hidden = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether to hide this admin from the graphical login screen.";
            };
          };
        }
      )
    );
    default = { };
    description = "Admin users with wheel and system management privileges.";
  };

  config = {
    users.users = lib.mapAttrs (username: uCfg: {
      enable = uCfg.enable;
      isNormalUser = true;
      description = lib.mkDefault uCfg.displayName;
      hidden = lib.mkDefault uCfg.hidden;
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
    }) config.maple.users.admins;
  };
}
