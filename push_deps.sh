#!/usr/bin/env nix-shell
#!nix-shell -i bash -p bash
set -e
command -v nix-build nix cachix >/dev/null

if [ "$1" -a "${1:1:1}" != "-" ]; then
    targets="$1"
    shift
else
    targets=$(
        nix eval --raw '(
            with import <nixpkgs/lib>;
            concatStringsSep "\n" (attrNames (import ./target.nix))
        )' |
        sort
    )
fi

for target in $targets; do
    echo "Building deps of $target" >&2
    nix build -f . $target.deps --no-link "$@"
    echo "Pushing deps of $target" >&2
    if ! nix-build . -A $target.deps --no-out-link | cachix push init-runner; then
        echo "Failed to push deps of $target" >&2
        exit 1
    fi
done
