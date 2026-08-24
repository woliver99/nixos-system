{ ... }:

{
  # sudo mkdir -p /persist/passwords && nix-shell -p mkpasswd --run "mkpasswd -m yescrypt" | sudo tee /persist/passwords/woliver99 && sudo chmod 600 /persist/passwords/woliver99
  # users.users.woliver99.hashedPasswordFile = "/persist/passwords/woliver99";

  # Disable the first-run lecture on ephemeral tmpfs root
  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';

  fileSystems."/".options = [
    "mode=755"
    "size=8G"
  ];

  fileSystems."/persist".neededForBoot = true;

  # -- Essential Hardware & Networking --

  # Wi-Fi networks and passwords
  fileSystems."/etc/NetworkManager/system-connections" = {
    device = "/persist/etc/NetworkManager/system-connections";
    fsType = "none";
    options = [ "bind" ];
  };

  # Paired Bluetooth devices
  fileSystems."/var/lib/bluetooth" = {
    device = "/persist/var/lib/bluetooth";
    fsType = "none";
    options = [ "bind" ];
  };

  # Save secureboot keys
  fileSystems."/var/lib/sbctl" = {
    device = "/persist/var/lib/sbctl";
    fsType = "none";
    options = [ "bind" ];
  };

  # Framework 13 Fingerprint sensor enrollments
  fileSystems."/var/lib/fprint" = {
    device = "/persist/var/lib/fprint";
    fsType = "none";
    options = [ "bind" ];
  };

  # -- System Logs & State --

  # Persistent systemd journal logs
  fileSystems."/var/log" = {
    device = "/persist/var/log";
    fsType = "none";
    options = [ "bind" ];
    neededForBoot = true;
  };

  # Systemd timer states, backlight levels, rfkill (airplane mode) state
  fileSystems."/var/lib/systemd" = {
    device = "/persist/var/lib/systemd";
    fsType = "none";
    options = [ "bind" ];
  };

  # System-wide Flatpaks
  fileSystems."/var/lib/flatpak" = {
    device = "/persist/var/lib/flatpak";
    fsType = "none";
    options = [ "bind" ];
  };

  # -- Machine Identity --

  # Preserves D-Bus identity, DHCP IP leases, and journal correlation
  environment.etc."machine-id".source = "/persist/etc/machine-id";

  # Automatically create backing directories on /persist if they don't exist yet
  systemd.tmpfiles.rules = [
    "d /persist/etc/NetworkManager/system-connections 0700 root root -"
    "d /persist/var/lib/bluetooth 0700 root root -"
    "d /persist/var/lib/sbctl 0700 root root -"
    "d /persist/var/lib/fprint 0700 root root -"
    "d /persist/var/log 0755 root root -"
    "d /persist/var/lib/systemd 0755 root root -"
    "d /persist/var/lib/flatpak 0755 root root -"
    "d /persist/etc 0755 root root -"
  ];
}
