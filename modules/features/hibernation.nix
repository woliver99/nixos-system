# This configuration allows the computer hibernate (DOES NOT WORK ON ANY OTHER COMPUTERS BUT MINE)

{ pkgs, ... }:

{
  swapDevices = [ { device = "/dev/disk/by-uuid/ac354139-cbdb-421c-86b9-89fed30e953e"; } ];
  boot.resumeDevice = "/dev/disk/by-uuid/ac354139-cbdb-421c-86b9-89fed30e953e";
  powerManagement.enable = true;
  
  # Hibernate won't work with this on certant intel laptops due to a problem in the kernel
  boot.blacklistedKernelModules = [ "intel_hid" ];

  
  boot.kernelParams = [
    # Suspend first
    "mem_sleep_default=deep"

    # Needed when your bootloader is grub
    "resume=/dev/disk/by-uuid/ac354139-cbdb-421c-86b9-89fed30e953e"
  ];

  services.power-profiles-daemon.enable = true;
  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";

  # Define time delay for hibernation
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=1m
    SuspendState=mem
  '';

  # Automatically switch power profiles based on AC power state
  services.udev.extraRules = ''
    # When AC power is plugged/unplugged, switch profile
    ACTION=="change", SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance"
    ACTION=="change", SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced"
  '';

  # Handle the initial state at boot time
  systemd.services.power-profile-on-boot = {
    description = "Set power profile based on AC state at boot";

    # This ensures the script runs AFTER the daemon is ready
    after = [ "power-profiles-daemon.service" ];

    # This is the key change:
    # It tells systemd to start this service as part of starting the daemon itself,
    # which creates a direct, non-cyclical dependency.
    wantedBy = [ "power-profiles-daemon.service" ];

    # The service runs once and then exits
    serviceConfig.Type = "oneshot";

    # The script to run, with the corrected logic
    script = ''
      # A short delay can sometimes help ensure the D-Bus interface is fully ready
      sleep 1

      # Use a robust numerical comparison to check the power state
      if [ "$(cat /sys/class/power_supply/AC*/online)" -eq 1 ]; then
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance
      else
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced
      fi
    '';
  };
}

