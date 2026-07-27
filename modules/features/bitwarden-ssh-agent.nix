# Bitwarden ssh agent setup (install Bitwarden flatpak)
{ ... }:

{
  environment.sessionVariables = {
    SSH_AUTH_SOCK = "$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock";
  };
}
