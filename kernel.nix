{ lib, stdenv, buildPackages, linuxManualConfig, linux_5_3 }: let

  inherit (stdenv.hostPlatform) kernelArch;

  inherit (linux_5_3) src version;
  defconfig = "defconfig";
  extraConfig = {
    CONFIG_MMC = "n";
    CONFIG_WIRELESS = "n";
    CONFIG_USB = "n";
    CONFIG_VIRTUALIZATION = "n";
    CONFIG_SOUND = "n";
    CONFIG_SUSPEND = "n";
    CONFIG_HIBERNATION = "n";
    CONFIG_PM = "n";

    CONFIG_ETHERNET = "n";
  };

  configfile = buildPackages.callPackage ({ stdenv, bison, flex }:
  stdenv.mkDerivation {
    name = "kernel.config";
    inherit src;
    nativeBuildInputs = [ bison flex ];
    buildPhase = ''
      set -x
      make ${defconfig} ARCH=${kernelArch}
      cat >>.config <<EOF
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${k}=${v}") extraConfig)}
      EOF

      sed --in-place \
        -e 's/=m$/=n/' \
        -e '/Platform selection/,/end of Platform selection/ s/=y$/=n/p' \
        .config

      set +x +o pipefail
      yes "" | make config ARCH=${kernelArch}
    '';
    installPhase = ''
      cp .config $out
    '';
  }) {};

  kernel = linuxManualConfig {
    inherit src version stdenv configfile;
    modDirVersion = version;
  };

in kernel
