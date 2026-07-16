{ ... }:

{
  users.users.colmena-deploy = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIRQPWV13EEsnHjDcfD9JKGcNvY9HXZV3YNFTl/dVX3J"
    ];
  };
}
