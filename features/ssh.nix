# Enable ssh access to this computer via ssh keys

{ ... }:

{
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  # Enable authentication via your running SSH agent
  security.pam.sshAgentAuth.enable = true;

  # Tell the sudo service specifically to use the SSH agent module
  security.pam.services.sudo.sshAgentAuth = true;

  # Force sudo to preserve your SSH socket connection string across environments
  security.sudo.extraConfig = ''
    Defaults env_keep += "SSH_AUTH_SOCK"
  '';
}
