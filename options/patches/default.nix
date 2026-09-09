# Reusable folder auto-importer for any directory's default.nix
{ lib, ... }:

let
  dirContents = builtins.readDir ./.;

  # Valid modules are:
  # 1. Regular .nix files (excluding default.nix)
  # 2. Subdirectories that have a default.nix inside them
  validFiles = lib.filterAttrs (
    name: type:
    (type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix")
    || (type == "directory" && builtins.pathExists (./. + "/${name}/default.nix"))
  ) dirContents;
in
{
  imports = map (name: ./. + "/${name}") (builtins.attrNames validFiles);
}
