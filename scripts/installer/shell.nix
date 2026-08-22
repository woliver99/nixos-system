{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  packages = [
    (pkgs.python313.withPackages (ps: with ps; [ rich ]))
    pkgs.parted
    pkgs.cryptsetup
    pkgs.btrfs-progs
    pkgs.e2fsprogs
    pkgs.f2fs-tools
    pkgs.dosfstools
    pkgs.util-linux
  ];
}
