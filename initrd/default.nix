{ stdenv, buildPackages, hostPlatform, busybox, glibc, cpio
, cpioFormat ? "newc" }:

let
  busybox' = busybox.override {
    enableStatic = true;
  };

in stdenv.mkDerivation {
  pname = "init-runner-initrd";
  version = "0.0.0";

  src = ./init.d;

  depsBuildBuild = with buildPackages; [ cpio ];

  # glibc: https://github.com/NixOS/nixpkgs/issues/36947
  buildPhase = ''
    mkdir -p rootfs/{bin,dev,etc,lib,mnt,proc,sys,tmp}
    cp -r $src rootfs/etc/init.d
    cp -Pr ${busybox'}/{bin,sbin} rootfs

    find ${glibc}/lib -maxdepth 1 -name '*.so*' -print0 | xargs -0 cp -Pt rootfs/lib
    ln -s ld-linux-armhf.so.3 rootfs/lib/ld-linux.so.3

    cp ${stdenv.cc.cc}/${hostPlatform.config}/lib/libgcc_s.so.1 rootfs/lib
  '';

  installPhase = ''
    mkdir $out
    cd rootfs
    find . | cpio -o --format=${cpioFormat} >$out/initrd.img
  '';
}
