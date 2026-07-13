{ config, lib, ... }:

{
  options.maplenetwork.remoteBuild = {
    enable = lib.mkEnableOption "Enable Maple Network remote builder configuration";
  };

  config = lib.mkIf config.maplenetwork.remoteBuild.enable {
    nix = {
      distributedBuilds = true;

      buildMachines = [
        {
          hostName = "nix.lan.maplenetwork.ca";
          sshUser = "nix-ssh";
          # sudo bash -c 'mkdir -p /root/.ssh && touch /root/.ssh/remote_builder'
          # sudo bash -c 'chown -R root:root /root/.ssh && chmod 700 /root/.ssh && chmod 600 /root/.ssh/remote_builder'
          sshKey = "/root/.ssh/remote_builder";
          system = "x86_64-linux";
          maxJobs = 1;
          supportedFeatures = [
            "nixos-test"
            "benchmark"
            "kvm"
          ];
          protocol = "ssh-ng";
        }
      ];

      settings = {
        #max-jobs = lib.mkDefault 0;
        builders-use-substitutes = true;
      };
    };

    programs.ssh.knownHosts."nix.lan.maplenetwork.ca" = {
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFy2gbHBEXlh04qizZc7UoHQ47GH26vjZETylhv7j1ue";
    };

    maplenetwork.localCache.enable = lib.mkForce true; # Need to trust the harmonia cache key
  };
}
