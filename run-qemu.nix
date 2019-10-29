{ lib, writeTextFile, bash, genext2fs, qemu
, initrd, kernel, pkgsCross, qemuFlags
, standalone ? false
, checkRun ? true, checkRunTimeout ? "60s", checkRunMemory ? "256" }:
let
  inherit (pkgsCross.hostPlatform) qemuArch;

  prefix = lib.optionalString (!standalone);

in writeTextFile rec {
  name = "init-runner-qemu";

  executable = true;
  destination = "/bin/${name}";

  text = ''
    #!${prefix bash}/bin/sh -e
    DISK_ROOT="$1"
    if [ ! -d "$DISK_ROOT" ]; then
      echo "Usage: $0 DISK_ROOT" >&2
      exit 1
    fi

    BLOCKS=$(du -s "$DISK_ROOT" | awk '{print int($1 * 1.2) + 8;}')
    IMG=$(mktemp --suffix=".img")
    ${prefix "${genext2fs}/bin/"}genext2fs \
      --root "$DISK_ROOT" \
      --size-in-blocks "$BLOCKS" \
      --faketime \
      "$IMG"
    echo "Image created: $(stat -c %s "$IMG") bytes"

    MEMORY=''${MEMORY-1024}

    exec ${prefix "${qemu}/bin/"}qemu-system-${qemuArch} \
      -m $MEMORY \
      -kernel ${if standalone then "$(dirname $0)" else kernel}/Image \
      -initrd ${if standalone then "$(dirname $0)" else initrd}/initrd.img \
      -append "panic=1 rdinit=/sbin/init" \
      -no-reboot \
      -drive if=none,file="$IMG",format=raw,id=hd1 \
      -device virtio-blk-device,drive=hd1 \
      -serial mon:stdio \
      -nographic \
      ${qemuFlags} \
      $QEMU_FLAGS
  '';

  checkPhase = let
    # Unpatch test binaries
    patchelf = pkgsCross.buildPackages.patchelf;
  in ''
    ${bash}/bin/sh -n $out/bin/${name}
  '' + lib.optionalString checkRun ''
    export MEMORY=${checkRunMemory}

    mkdir -p disk/bin
    install -Dm755 ${pkgsCross.hello}/bin/hello disk/bin
    intp=$(${patchelf}/bin/patchelf --print-interpreter disk/bin/hello |
      sed -nE 's%/nix/store/[^/]*(/.*)%\1%p')
    ${patchelf}/bin/patchelf --set-interpreter "$intp" disk/bin/hello

    cp $out/bin/${name} ./
    ${lib.optionalString standalone ''
      export PATH=$PATH:${genext2fs}/bin:${qemu}/bin
      ln -s ${kernel}/Image Image
      ln -s ${initrd}/initrd.img initrd.img
    ''}
    content=$(
      timeout ${checkRunTimeout} ${bash}/bin/sh ./${name} disk 2>&1 |
      tee /dev/stderr)
    echo "$content" | grep -q "Hello, world!"
    echo "$content" | grep -q "init-runner: All tasks done"
  '';
}
