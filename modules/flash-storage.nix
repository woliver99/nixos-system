# Common config for flash storage to save lifespan

{ lib, config, ... }:

{
  zramSwap = {
    enable = true;
    memoryPercent = lib.mkDefault 100;
  };

  boot.kernel.sysctl = {
    # Aggressively favor swapping out idle processes to zram
    "vm.swappiness" = 180;

    # Start background writes as soon as there is just 4MB of dirty data in RAM
    "vm.dirty_background_bytes" = 4194304; # 4 MB

    # Block processes from creating more dirty data if it hits 16MB
    # This guarantees a flush will never take more than a fraction of a second
    "vm.dirty_bytes" = 16777216; # 16 MB
  };

  # Mounts /tmp in RAM. Protects SD card during Nix builds.
  boot.tmp = {
    useTmpfs = lib.mkDefault true;
    tmpfsSize = lib.mkDefault "80%"; # Can expand up to 80% of total memory (including zram swap)
  };

  fileSystems."/".options = [
    "noatime" # Stop the OS from writing file access timestamps
    "lazytime" # Delays inode timestamp updates in RAM
    "nodiscard" # Prevents continuous hardware erase stutters on cheap SD cards
  ]
  ++ lib.optionals (config.fileSystems."/".fsType == "f2fs") [
    # Compresses files BEFORE they hit the storage, drastically cutting down physical writes.
    "compress_algorithm=zstd"
    "compress_chksum"

    "atgc" # Enables aggressive background garbage collection in F2FS
    "gc_merge" # Merges user I/O and background GC to prevent stutters
  ];

  # Force system logs to stay in RAM and never touch the disk
  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=50M
  '';
}
