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

}
