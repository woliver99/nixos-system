# GPU passthrough configuration, this is currently only setup for my computer so do not use this without modification since it will break your system, i will work on making it more modular in the future

{ lib, ... }:

{
  specialisation = {
    "gpu-passthrough" = {
      configuration = {
        # Disable Nvidia
        services.xserver.videoDrivers = lib.mkForce [ "modesetting" ];
        #hardware.nvidia.prime.offload = {
        #enable = lib.mkForce false;
        #enableOffloadCmd = lib.mkForce false;
        #};

        # Installation dependent
        boot.kernelParams = [
          "intel_iommu=on"
          # Choose what CPU cores to dedicate to the VM
          "isolcpus=1,2,3,4,5,7,8,9,10,11"
        ];

        boot.initrd.availableKernelModules = [
          "vfio_pci"
          "vfio"
          "vfio_iommu_type1"
        ];

        boot.blacklistedKernelModules = [
          # NVIDIA drivers
          "nouveau"
          "nvidia"

          # AMD drivers
          "amdgpu"
          "radeon" # For older AMD cards

          # Controller drivers
          "xpad"
        ];

        # Installation dependent
        boot.extraModprobeConfig = "options vfio-pci ids=10de:1f14,10de:10f9,10de:1ada,10de:1adb disable_vga=1";

        virtualisation.libvirtd = {
          enable = true;
          #qemu.ovmf = {
          #  enable = true;
          #  packages = [ pkgs.OVMFFull.fd ];
          #};
        };

        virtualisation.spiceUSBRedirection.enable = true;
        users.groups.libvirtd.members = [ "woliver99" ];
        services.spice-vdagentd.enable = true;

        programs.virt-manager.enable = true;
        # Installation dependent
        users.users.woliver99.extraGroups = [
          "libvirtd"
          "spice-usb"
        ];

      };
    };
  };
}
