{ stdenv, buildPackages }:
stdenv.mkDerivation {
  name = "init-runner-check";

  dontUnpack = true;
  dontPatch = true;
  dontConfigure = true;

  source = ''
    #include <stdio.h>
    int main (void) {
      printf("Hello, world!\n");
      return 0;
    }
  '';

  buildPhase = ''
    echo "$source" >hello.c
    $CC hello.c -o hello
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp hello $out/bin
  '';

  # Unpatch ELF so it can be run inside QEMU
  fixupPhase = ''
    for f in $out/bin/*; do
      intp=$(${buildPackages.patchelf}/bin/patchelf --print-interpreter $f |
        sed -nE 's%/nix/store/[^/]*(/.*)%\1%p')
      ${buildPackages.patchelf}/bin/patchelf --set-interpreter "$intp" $f
    done
  '';
}
