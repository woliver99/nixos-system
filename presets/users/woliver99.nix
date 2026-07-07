{ ... }:

{
  users.users.woliver99 = {
    isNormalUser = true;
    description = "Oliver Wuthrich-Giroux";

    extraGroups = [
      "wheel"
      "networkmanager"
      "adbusers"
      "dialout"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJFA92sJeSZTTssuN97rDOfSh0UvR3pOpUUDr/6Xqw8q"
    ];
  };

  programs.git.config.user = {
    name = "woliver99";
    email = "oliver@maplenetwork.ca";
  };
}
