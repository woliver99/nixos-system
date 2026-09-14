{
  config,
  lib,
  ...
}:

let
  cfg = config.maple.system.kvm;
in
{
  options.maple.system.kvm = {
    enable = lib.mkEnableOption "virt manager";

    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "woliver99" ];
      description = "Users granted access to libvirt and KVM virtualization.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.virt-manager.enable = true;
    virtualisation.libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };

    users.users = lib.genAttrs cfg.users (_name: {
      extraGroups = [
        "libvirtd"
        "kvm"
      ];
    });
    environment.sessionVariables = {
      LIBVIRT_DEFAULT_URI = [ "qemu:///system" ];
    };
  };
}
