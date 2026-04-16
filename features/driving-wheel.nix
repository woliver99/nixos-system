{ pkgs, ... }:

{
  # Enable the custom Logitech Force Feedback kernel module
  hardware.new-lg4ff.enable = true;

  # Install Oversteer for graphical configuration
  environment.systemPackages = with pkgs; [
    oversteer
  ];

  # Ensure the udev rules from Oversteer are applied so your user can access the wheel
  services.udev.packages = with pkgs; [ oversteer ];

  # Auto-switch Logitech G920 from Xbox mode to PC mode
  services.udev.extraRules = ''
    ATTR{idVendor}=="046d", ATTR{idProduct}=="c261", RUN+="${pkgs.usb-modeswitch}/bin/usb_modeswitch -v 046d -p c261 -M 0f00010142 -C 0x03 -m 01 -r 01"
  '';
}
