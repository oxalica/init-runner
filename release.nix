(import <nixpkgs/lib>).mapAttrs (k: v: v.package) (import ./.)
