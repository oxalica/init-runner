# init-runner

[![Build Status](https://travis-ci.org/oxalica/init-runner.svg?branch=master)](https://travis-ci.org/oxalica/init-runner)

init-runner is a set of minimized Linux runtime for multiple platforms,
with out-of-the-box [QEMU][qemu] startup scripts,
making cross-platform testing to be easier.

init-runner consists of a cusomized Linux kernel, an initrd image and a QEMU startup script.

The init in initrd image will run all executables in disk (see below) as tests,
and poweroff the machine when finished.

## Usage

It is strongly recommended to use binary distribution on [GitHub Release][releases].
If you still want to build from source, see the section below.

1. Install dependencies:
   - qemu
   - genext2fs
2. Download and extract released tarball of any platform you like.
3. `cd` into the `init-runner` directory extracted.
4. Run `./init-runner-qemu <DIR>`, where `<DIR>` is the directory
   containing your cross-binaries to be tested.
5. Just wait it to run all your binaries, print outputs to stdout,
   and exit when things done.

## Use in CI (continuous integration)

**TODO**

## Provided platforms

- aarch64-unknown-linux-gnu
- armv7l-unknown-linux-gnueabihf
- mips-unknown-linux-gnu
- mipsel-unknown-linux-gnu

Linux kernel version is given in file name of [released tarballs][releases]

Note: [glibc][glibc] and gcc runtime libraries are packaged in initrd image.
Feel free about running dynamic linked executables.


## Customize running

By default, init-runner will run all executable regular files directly under `<DIR>`,
non-recursively, where `<DIR>` is first argument passed to `init-runner-qemu`.

You can also put executables in `<DIR>/bin`.
If it exists, only executables in `<DIR>/bin` will be runned, recursively.

A extra file `<DIR>/.env` can be provided to control the arguments,
environment variables, and more.
You can read [initrd/example.env][example.env] for more information.

## Replacing Linux kernel

If you want to use another version and/or configuration of Linux kernel.
You can simply replace the `vmlinux` file in the extracted tarball.

Remember to target compatible arch/mechine, and enable necessary features (like initrd)
and drivers (like pci and virtio).

## Build from source

**TODO**

## License

MIT Licensed

[qemu]: https://www.qemu.org/
[glibc]: https://www.gnu.org/software/libc/
[releases]: https://github.com/oxalica/init-runner/releases
[example.env]: https://github.com/oxalica/init-runner/blob/master/initrd/example.env
