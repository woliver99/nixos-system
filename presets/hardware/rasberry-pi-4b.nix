{ ... }:

{
  imports = [
    ../../modules/server.nix
  ];

  zramSwap.enable = true;
}
