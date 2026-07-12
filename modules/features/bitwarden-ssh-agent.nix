# Bitwarden ssh agent setup (install Bitwarden flatpak)
{ lib, ... }:

{
  programs.bash.interactiveShellInit = ''
    export SSH_AUTH_SOCK="$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock"
  '';

  programs.git.config = {
    # Tell Git to use SSH for signing instead of GPG
    gpg.format = "ssh";

    # Turn on signing automatically for every single commit you make
    commit.gpgsign = true;
  };
}
