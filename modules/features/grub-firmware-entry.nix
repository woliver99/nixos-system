# Adds a dedicated menu entry to GRUB to reboot directly into UEFI Firmware (BIOS) settings.

{ ... }:

{
  boot.loader.grub.extraInstallCommands = ''
    cfg=$out/boot/grub/grub.cfg

    echo "
      menuentry 'Reboot to UEFI/BIOS Setup' {
        fwsetup
      }
    " >> $cfg
  '';
}
