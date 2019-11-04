(import <nixpkgs/lib>).mapAttrs (config:
{ platform, qemuFlags ? "", kernelConfigure ? "", kernelInstall ? null }: let
  version = "0.0.0";

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

}) (import ./target.nix)
