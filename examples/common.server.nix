{ ... }:

{
  imports = [
    # -- Common --
    ./nixos-system/common/server.nix # Common config for every server

    # -- Modules --
    #./nixos-system/modules/flash-storage.nix # Adds optimisations for sd card storage lifespan
  ];
}
