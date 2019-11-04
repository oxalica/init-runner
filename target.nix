with import <nixpkgs/lib>; {

  aarch64-unknown-linux-gnu = {
    platform = systems.examples.aarch64-multiplatform;
    qemuFlags = "-M virt -cpu cortex-a72";
    kernelConfigure = ''
      sed --in-place \
        -e '/^# Platform selection$/,/^# end of Platform selection$/ s/=y$/=n/p' \
        .config
      cat >>.config <<EOF
      CONFIG_MFD_CORE=n
      EOF
    '';
  };

  armv7l-unknown-linux-gnueabihf = {
    # Kernel target is `zImage` here. `Image` doesn't boot.
    platform = systems.examples.armv7l-hf-multiplatform;
    qemuFlags = "-M virt -cpu cortex-a15";
    kernelConfigure = ''
      sed --in-place \
        -e '/^CONFIG_ARCH_VIRT=/,/^# end of System Type$/ s/=y$/=n/p' \
        .config
      cat >>.config <<EOF
      CONFIG_ARCH_VIRT=y
      CONFIG_PINCTRL=n
      CONFIG_GPIOLIB=n
      CONFIG_NEW_LEDS=n
      CONFIG_MFD=n
      EOF
    '';
  };

  mips-unknown-linux-gnu = {
    qemuFlags = "-M malta";
    platform = {
      config = "mips-unknown-linux-gnu";
      platform = {
        gcc.abi = "32";
        kernelArch = "mips";
        kernelTarget = "vmlinux";
        kernelBaseConfig = "malta_defconfig";
      };
    };
    kernelConfigure = ''
      cat >>.config <<EOF
      CONFIG_CPU_LITTLE_ENDIAN=n
      CONFIG_CPU_BIG_ENDIAN=y
      CONFIG_BLK_DEV_INITRD=y
      EOF
    '';
    # `make install` requires `vmlinuz`, but we only build `vmlinux`.
    kernelInstall = attrs: ''
      mkdir $out
      install -Dm 755 vmlinux $out
      install -Dm 644 System.map $out
    '';
  };

  mipsel-unknown-linux-gnu = {
    qemuFlags = "-M malta";
    platform = {
      config = "mipsel-unknown-linux-gnu";
      platform = {
        gcc.abi = "32";
        kernelArch = "mips";
        kernelTarget = "vmlinuz";
        kernelBaseConfig = "malta_defconfig";
      };
    };
    kernelConfigure = ''
      cat >>.config <<EOF
      CONFIG_BLK_DEV_INITRD=y
      EOF
    '';
    kernelInstall = attrs: ''
      mkdir $out
      install -Dm 755 vmlinux $out
      install -Dm 644 System.map $out
    '';
  };
}
