# Common config for every system

{ ... }:

{
  imports = [
    ../features/shell-shortcuts.nix # Usefull shell shortcuts I like to have in my terminal
    ../features/custom-options.nix # Custom nix configuration options for easier customizations
  ];

  # Official community CUDA binary cache
  nix.settings = {
    substituters = [ "https://cache.nixos-cuda.org" ];
    trusted-public-keys = [ "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=" ];
  };
}
