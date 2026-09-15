{ lib, ... }:

{
  imports = [
    (lib.mkRenamedOptionModule
      [ "profiles" "proxmox" "enable" ]
      [ "maple" "profiles" "proxmox" "enable" ]
    )
  ];
}
