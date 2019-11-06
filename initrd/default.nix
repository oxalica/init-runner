{ lib, stdenv, buildPackages, hostPlatform, busybox, glibc, cpio
, cpioFormat ? "newc" }:

let
  busybox' = busybox.override {
    enableStatic = true;
  };

in stdenv.mkDerivation {
  name = "init-runner-initrd";

  src = ./init.d;

  depsBuildBuild = with buildPackages; [ cpio ];

  # glibc: https://github.com/NixOS/nixpkgs/issues/36947
  buildPhase = ''
    mkdir -p rootfs/{bin,dev,etc,lib,mnt,proc,sys,tmp}
    cp -r $src rootfs/etc/init.d
    cp -Pr ${busybox'}/{bin,sbin} rootfs

    find ${glibc}/lib -maxdepth 1 -name '*.so*' -print0 | xargs -0 cp -Pt rootfs/lib

    cp ${stdenv.cc.cc}/${hostPlatform.config}/lib${lib.optionalString hostPlatform.is64bit "64"}/libgcc_s.so.1 \
      rootfs/lib
  '';

  installPhase = ''
    mkdir $out
    cd rootfs
    find . | cpio -o --format=${cpioFormat} >$out/initrd.img
  '';
}
