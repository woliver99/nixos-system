# Usefull shell shortcuts I like to have in my terminal

{ ... }:

{
  programs.bash.shellAliases = {
    editconfig = "cd /etc/nixos/";
    explorer = "(xdg-open . > /dev/null 2>&1 &)";
    sys-update = "editconfig &&  sudo bash ./nixos-system/scripts/update.sh";
    sys-dryupdate = "editconfig && sudo bash ./nixos-system/scripts/update.sh --dry-run";
  };
}
