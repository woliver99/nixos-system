{ config, lib, ... }:

let
  cfgLocal = config.maplenetwork.localCache;
  cfgCuda = config.features.cudaCache;
in
{
  options = {
    maplenetwork.localCache.enable = lib.mkEnableOption "Maple Network local binary cache";
    features.cudaCache.enable = lib.mkEnableOption "Community CUDA binary cache profile";
  };

  config = lib.mkMerge [
    (lib.mkIf cfgLocal.enable {
      nix.settings = {
        substituters = [ "https://nix.maplenetwork.ca" ];
        trusted-public-keys = [ "nix.lan.maplenetwork.ca:b7H0vKiHzYOBDyeLYuX07Tg/TjWdLIP/n0v2+HQY8gs=" ];
      };
    })

    (lib.mkIf cfgCuda.enable {
      nix.settings = {
        substituters = [ "https://cache.nixos-cuda.org" ];
        trusted-public-keys = [ "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=" ];
      };
    })
  ];
}
