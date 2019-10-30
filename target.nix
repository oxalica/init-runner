with import <nixpkgs/lib>; {

  aarch64-unknown-linux-gnu = {
    platform = systems.examples.aarch64-multiplatform;
    qemuFlags = "-M virt -cpu cortex-a72";
  };

  armv7l-unknown-linux-gnueabihf = {
    platform = systems.examples.armv7l-hf-multiplatform;
    qemuFlags = "-M virt -cpu cortex-a15";
  };

}
