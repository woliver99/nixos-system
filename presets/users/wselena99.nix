{ ... }:

{
  users.users.wselena99 = {
    isNormalUser = true;
    description = "Selena Wuthrich-Giroux";

    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };
}
