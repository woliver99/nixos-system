# Common config for a standard ovh vps

{ ... }:

{
  imports = [
    ../../modules/virtual-machine.nix
    ../../modules/server.nix
  ];
}
