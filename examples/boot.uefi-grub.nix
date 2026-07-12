{ ... }:

{
  imports = [
    ./nixos-system/modules/features/grub-firmware-entry.nix # Adds a "Reboot to UEFI" entry
    #./nixos-system/modules/features/grub-dualboot.nix # Adds other operating systems (like Windows) to grub
  ];

  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
    };
    efi.canTouchEfiVariables = true;
  };
}
