{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.maplenetwork.colmenaDeploy;
in
{
  options.maplenetwork.colmenaDeploy = {
    enable = lib.mkEnableOption "the hardened colmena deployment user and sudo rules";
  };

  config = lib.mkIf cfg.enable {
    users.groups.colmena-deploy = { };

    users.users.colmena-deploy = {
      isSystemUser = true;
      group = "colmena-deploy";

      createHome = true;
      home = "/var/lib/colmena";
      homeMode = "700";
      shell = pkgs.bash;

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIRQPWV13EEsnHjDcfD9JKGcNvY9HXZV3YNFTl/dVX3J"
      ];
    };

    security.sudo.extraRules = [
      {
        users = [ "colmena" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
