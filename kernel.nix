{ lib, stdenv, buildPackages, linuxManualConfig, linux_5_3
, kernelConfigure }: let

  inherit (stdenv.hostPlatform.platform) kernelArch kernelBaseConfig kernelTarget;

  inherit (linux_5_3) src version;
  extraConfig = {
    CONFIG_MMC = "n";
    CONFIG_VIRTUALIZATION = "n";
    CONFIG_SOUND = "n";
    CONFIG_SUSPEND = "n";
    CONFIG_HIBERNATION = "n";
    CONFIG_THERMAL = "n";
    CONFIG_USB_SUPPORT = "n";
    CONFIG_ETHERNET = "n";
    CONFIG_WIRELESS = "n";
    CONFIG_WLAN = "n";
    CONFIG_DRM = "n";
    CONFIG_MEDIA_SUPPORT = "n";
    CONFIG_REGULATOR = "n";
    CONFIG_NFS_FS = "n";
  };

  configfile = buildPackages.callPackage ({ stdenv, bison, flex }:
  stdenv.mkDerivation {
    name = "kernel.config";
    inherit src;
    nativeBuildInputs = [ bison flex ];
    buildPhase = ''
      set -x
      make ${kernelBaseConfig} ARCH=${kernelArch}
      cat >>.config <<EOF
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "${k}=${v}") extraConfig)}
      EOF
      ${kernelConfigure}
      sed --in-place 's/=m$/=n/' .config
      set +x +o pipefail
      yes "" | make config ARCH=${kernelArch}
    '';
    installPhase = ''
      cp .config $out
    '';
  }) {};

  kernel = linuxManualConfig {
    inherit src version configfile;
    modDirVersion = version;
    stdenv = stdenv.override {
      hostPlatform = stdenv.hostPlatform // {
        platform = {
          inherit (stdenv.hostPlatform) gcc;
          inherit kernelArch kernelTarget;
          kernelDTB = false;
        };
      };
    };
  };

in kernel
