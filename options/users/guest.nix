{ config, lib, ... }:

{
  options.maple.users.guest = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "Display name for a passwordless guest account.";
  };

  config = lib.mkIf (config.maple.users.guest != null) {
    maple.users.guests.guest.description = config.maple.users.guest;
    users.users.guest.password = "";
  };
}
