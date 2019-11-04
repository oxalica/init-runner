{ runCommand
, version
, initrd, kernel, run-qemu, pkgsCross }:

let
  name = "init-runner-${version}-linux-${kernel.version}-${pkgsCross.hostPlatform.config}";

  run-qemu' = run-qemu.override {
    standalone = true;
  };

in runCommand name {} ''
  mkdir init-runner
  cp -t init-runner ${initrd}/initrd.img ${kernel}/vmlinux ${run-qemu'}/bin/init-runner-qemu

  mkdir -p $out/dist
  tar -czf $out/dist/${name}.tar.gz init-runner
''
