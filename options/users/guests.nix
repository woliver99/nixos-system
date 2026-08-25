{ config, lib, ... }:

{
  options.maple.users.guests = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }: {
          options = {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether to create this guest account.";
            };
            displayName = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = "Display name of the guest account.";
            };
          };
        }
      )
    );
    default = { };
    description = "Unprivileged accounts.";
  };

  config = {
    users.users = lib.mapAttrs (username: uCfg: {
      enable = uCfg.enable;
      isNormalUser = true;
      description = lib.mkDefault uCfg.displayName;
      password = "";
      extraGroups = [ "networkmanager" ];
    }) config.maple.users.guests;
  };
}
