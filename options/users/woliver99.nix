{ config, lib, ... }:

let
  cfg = config.maple.users.woliver99;
in
{
  options.maple.users.woliver99 = {
    enable = lib.mkEnableOption "Oliver's user";
    hidden = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to hide Oliver's user from the graphical login screen.";
    };
  };

  config = lib.mkIf cfg.enable {
    maple.users.admins.woliver99 = {
      displayName = "Oliver Wuthrich-Giroux";
      hidden = lib.mkDefault cfg.hidden;
    };

    users.users.woliver99 = {
      extraGroups = [ "dialout" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJFA92sJeSZTTssuN97rDOfSh0UvR3pOpUUDr/6Xqw8q"
      ];
    };

    programs.git.config = lib.mkMerge [
      {
        user = {
          name = "woliver99";
          email = "oliver@maplenetwork.ca";
          signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDoW8s3QavyRRSUlMAUiEmgz/E0/FbzJaajxZ+lxhPnS";
        };
      }
      (lib.mkIf config.maple.apps.bitwarden.enable {
        url."git@github.com:woliver99/" = {
          insteadOf = "https://github.com/woliver99/";
        };
      })
    ];
  };
}
