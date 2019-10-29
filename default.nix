(import <nixpkgs/lib>).mapAttrs (config: { platform, qemuFlags ? "" }: let
  version = "0.0.0";

  pkgsCross = import <nixpkgs> { crossSystem = platform; };
  pkgs = import <nixpkgs> {};

in rec {

  initrd = pkgsCross.callPackage ./initrd {};

  kernel = pkgsCross.linux_5_3;

  run-qemu = pkgs.callPackage ./run-qemu.nix {
    inherit initrd kernel pkgsCross qemuFlags;
  };

  package = pkgs.callPackage ./package.nix {
    inherit version initrd kernel run-qemu pkgsCross;
  };

}) (import ./target.nix)
