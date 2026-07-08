# Configures GRUB for dual-boot environments:
# 1. Scans for other operating systems (like Windows).
# 2. Remembers and defaults to the last selected entry on next boot.

{ ... }:

{
  boot.loader.grub = {
    useOSProber = true;
    default = "saved";
  };
}
