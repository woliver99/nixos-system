{ lib, ... }:

{
  users.users.user = {
    isNormalUser = true;
    description = lib.mkDefault "User";
    password = ""; # Passwordless

    extraGroups = [
      "networkmanager"
      "video"
      "render"
    ];
  };
}
