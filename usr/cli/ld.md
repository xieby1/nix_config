---
layout: default
title: Binutils and gcc collsion
parent: usr/cli
---

# binutils's ld and gcc's ld collsion

Background: I want to install `gcc` and `objdump`, where `objdump` is contained in `binutils`.
Home-manager tolds me `gcc`'s `ld` collides with `binutils`'s `ld`.
As I explore into `gcc` and `binutils`, weird thing comes.

Packages `binutils` and `gcc` both contain ld executable.
`binutils` and `gcc` has the same priority 10.

The WEIRD thing is,

* `binutils` wants to have a lower priority than gcc-wrapper,
  so sets its priority to 10,
  see nixpkgs: `pkgs/development/tools/misc/binutils/default.nix`
  > Give binutils a lower priority than gcc-wrapper to prevent a
  > collision due to the ld/as wrappers/symlinks in the latter.
* Both `gcc` wrapper and all-packages set gcc priority to 10,
  see nixpkgs: `pkgs/top-level/all-packages.nix` and
  `pkgs/build-support/cc-wrapper/default.nix`
  All-packages set priority by lowPrio function,
  which will set priority to 10.
  Cc-wrapper directly set priority to 10.

As a result, `binutils` will definitely collide with `gcc`!

My solution: assign `binutils` a lower priority, like this

```nix
home.packages = with pkgs; [
  (lib.setPrio # higher value, less prior
    (bintools-unwrapped.meta.priority + 1)
    bintools-unwrapped
  )
  gdb
]
```
