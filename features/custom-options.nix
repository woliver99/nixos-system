{ config, lib, ... }:

{
  # Define the custom option for ANY user
  options.users.users = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options.hidden = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to hide this user from the graphical login screen.";
        };
      }
    );
  };

  # Generate the systemd-tmpfiles rules dynamically
  config =
    let
      # Filter out only the users that have `hidden = true`
      hiddenUsers = lib.filterAttrs (name: userConfig: userConfig.hidden) config.users.users;

      # Map those users into the exact systemd tmpfiles rule format
      makeTmpfilesRule =
        name: "f+ /var/lib/AccountsService/users/${name} 0644 root root - [User]\\nSystemAccount=true";
    in
    {
      # Feed the generated list of rules into systemd
      systemd.tmpfiles.rules = lib.mapAttrsToList (name: _: makeTmpfilesRule name) hiddenUsers;
    };
}
