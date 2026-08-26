{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.maple.apps.bitwarden;
in
{
  options.maple.apps.bitwarden = {
    enable = lib.mkEnableOption "Bitwarden (Flatpak version) with biometric and SSH agent support";
  };

  config = lib.mkIf cfg.enable {
    maple.system.flatpak = {
      enable = true;
      packages = [ "com.bitwarden.desktop" ];
    };

    # Enable ssh agent in settings to utilise this
    environment.sessionVariables = {
      SSH_AUTH_SOCK = "$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock";
    };

    # Forward ssh agent - TODO: Find alternative than ssh forwarding
    programs.ssh.extraConfig = ''
      # Automatically resolve short names using your local search domain
      CanonicalizeHostname yes
      CanonicalDomains lan.maplenetwork.ca

      # Matches after canonicalization expands "edge" to "edge.lan.maplenetwork.ca"
      Host *.lan.maplenetwork.ca
        ForwardAgent yes
    '';

    # Allow biometric unlock
    environment.systemPackages = with pkgs; [
      (writeTextFile {
        name = "bitwarden-polkit-policy";
        destination = "/share/polkit-1/actions/com.bitwarden.Bitwarden.policy";
        text = ''
          <?xml version="1.0" encoding="UTF-8"?>
          <!DOCTYPE policyconfig PUBLIC
           "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
           "http://www.freedesktop.org/standards/PolicyKit/1.0/policyconfig.dtd">

          <policyconfig>
              <action id="com.bitwarden.Bitwarden.unlock">
                <description>Unlock Bitwarden</description>
                <message>Authenticate to unlock Bitwarden</message>
                <defaults>
                  <allow_any>no</allow_any>
                  <allow_inactive>no</allow_inactive>
                  <allow_active>auth_self</allow_active>
                </defaults>
              </action>
          </policyconfig>
        '';
      })
    ];

    # -- Allow Bitwarden extension in Brave to use biometric unlock --
    systemd.tmpfiles.rules = [
      "L+ /var/lib/flatpak/overrides/com.bitwarden.desktop - - - - ${pkgs.writeText "com.bitwarden.desktop" ''
        [Context]
        filesystems=xdg-config/BraveSoftware/Brave-Browser/NativeMessagingHosts;
      ''}"
    ];

    # Symlink Flatpak IPC socket to the host cache path expected by the proxy
    systemd.user.tmpfiles.rules = [
      "L+ %h/.cache/com.bitwarden.desktop/s.bw - - - - %h/.var/app/com.bitwarden.desktop/cache/com.bitwarden.desktop/s.bw"
    ];

    programs.nix-ld.enable = true; # Needed for Bitwarden native messaging proxy
  };
}
