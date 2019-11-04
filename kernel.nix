{ lib, stdenv, buildPackages, linuxManualConfig, writeTextFile
, linux_5_3, utillinuxMinimal
, kernelConfigure, kernelInstall }: let

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

  installkernel = writeTextFile {
    name = "installkernel";
    executable = true;
    text = ''
      #!${stdenv.shell} -e
      mkdir -p "$4"
      cp -av "$2" "$4/vmlinux"
      cp -av "$3" "$4/System.map"
    '';
  };

  kernel = (linuxManualConfig {
    inherit src version configfile;

    stdenv = stdenv.override {
      hostPlatform = lib.recursiveUpdate stdenv.hostPlatform {
        platform.kernelDTB = false;
      };
    };

  }).overrideAttrs (attrs: {
    # Override utillinux -> utillinuxMinimal to shrink deps.
    nativeBuildInputs =
      lib.filter (pkg: pkg.pname or null != "util-linux") attrs.nativeBuildInputs
      ++ [ utillinuxMinimal ];

    buildFlags = [
      "KBUILD_BUILD_VERSION=init-runner-os"
      stdenv.hostPlatform.platform.kernelTarget
      "vmlinux"
    ];

    installFlags = [
      "INSTALLKERNEL=${installkernel}"
      "INSTALL_PATH=$(out)"
    ];
  } // lib.optionalAttrs (kernelInstall != null) {
    installPhase = kernelInstall attrs;
  });

in kernel
