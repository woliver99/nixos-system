# Preset for the Dell Latitude 3310 laptop

{ ... }:

{
  # -- Config --
  imports = [
    ../../../pkgs/nixos-hardware/dell/latitude/3310 # Import from nixos-hardware repository
  ];
}
