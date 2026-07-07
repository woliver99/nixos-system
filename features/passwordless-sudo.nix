# Allows the use of sudo without a password (Security Warning)

{ ... }:

{
  security.sudo.wheelNeedsPassword = false;

  warnings = [
    "Passwordless sudo is dangerous and is replaced with ssh agent built into the ssh module"
  ];
}
