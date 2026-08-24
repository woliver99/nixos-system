# Enables Flatpak and make the default repository available to all users

{ pkgs, ... }:

{
  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    description = "Installs the default Flatpak repo";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
}
