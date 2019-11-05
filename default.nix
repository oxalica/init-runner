(import <nixpkgs/lib>).mapAttrs (config:
{ platform, qemuFlags ? "", kernelConfigure ? "", kernelInstall ? null }: let
  version = "0.1.0";

  pkgsCross = import <nixpkgs> { crossSystem = platform; };
  pkgs = import <nixpkgs> {};

in rec {

  initrd = pkgsCross.callPackage ./initrd {};

  kernel = pkgsCross.callPackage ./kernel.nix {
    inherit kernelConfigure kernelInstall;
  };

  run-qemu = pkgs.callPackage ./run-qemu.nix {
    inherit initrd kernel pkgsCross qemuFlags;
    check = pkgsCross.callPackage ./check.nix {};
  };

  package = pkgs.callPackage ./package.nix {
    inherit version initrd kernel run-qemu pkgsCross;
  };

  # Build dependencies to be cached. Compilers, libc, etc.
  deps = [
    pkgsCross.stdenv
    pkgsCross.glibc
    (pkgsCross.busybox.override { enableStatic = true; })
    pkgsCross.buildPackages.utillinuxMinimal
  ];

}) (import ./target.nix)
