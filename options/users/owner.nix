{ config, lib, ... }:

{
  options.maple.users.owner = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "Display name for the device's owner.";
  };

  config = lib.mkIf (config.maple.users.owner != null) {
    maple.users.admins.owner.description = config.maple.users.owner;
  };
}
