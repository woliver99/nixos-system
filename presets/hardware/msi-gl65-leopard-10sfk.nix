# Preset for the GL65 Leopard laptop: https://www.msi.com/Laptop/GL65-Leopard-10SX/Specification
# Tested on: GL65 Leopard 10SFK-206CA

{
  lib,
  config,
  pkgs,
  ...
}:

let
  # These create a high-priority "fake" package that contains only the modified desktop file.
  patchDesktop =
    pkg: appName: from: to:
    lib.hiPrio (
      pkgs.runCommand "$patched-desktop-entry-for-${appName}" { } ''
        ${pkgs.coreutils}/bin/mkdir -p $out/share/applications
        ${pkgs.gnused}/bin/sed 's#${from}#${to}#g' < ${pkg}/share/applications/${appName}.desktop > $out/share/applications/${appName}.desktop
      ''
    );

  # Function to wrap an app with nvidia-offload
  GPUOffloadApp = pkg: desktopName: patchDesktop pkg desktopName "^Exec=" "Exec=nvidia-offload ";
in
{
  # -- Config --
  imports = [
    ../../nixos-hardware/msi/gl65 # Import from nixos-hardware repository
  ];

  hardware.nvidia.open = false;

  environment.systemPackages = lib.mkIf (!(lib.elem "battery-saver" config.system.nixos.tags)) [
    (GPUOffloadApp pkgs.steam "steam")
  ];

  # Enable battery saver specialisation from nixos-hardware
  hardware.nvidia.primeBatterySaverSpecialisation = true;
  specialisation."battery-saver".configuration = {
    hardware.nvidia.prime.offload.enableOffloadCmd = lib.mkForce false;

    # RE-ENABLE SLEEP & SUSPEND
    systemd.targets.sleep.enable = lib.mkForce true;
    systemd.targets.suspend.enable = lib.mkForce true;
    systemd.targets.hibernate.enable = lib.mkForce true;
    systemd.targets.hybrid-sleep.enable = lib.mkForce true;
  };

  networking.interfaces.enp3s0.wakeOnLan.enable = true; # Wake On Lan

  # -- Fixes --

  # SSD fixes (probably not a laptop problem but keeping it here anyways)
  boot.kernelParams = [
    "nvme_core.default_ps_max_latency_us=0" # Fix NVMe SSD timeouts (prevent deep sleep)
    "pcie_aspm=off" # Uses more power but testing if this fixes a crash on boot
    "acpi_enforce_resources=lax" # This fixes the motherboard crash when Native ASPM is Enabled.
  ];

  # Disable all sleep and suspend states since it causes many problems with the Nvidia drivers
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
}
