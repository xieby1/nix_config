# Auto Push Packages to Cachix

**Objective**:
Automatically push specific built packages to cachix during `home-manager switch`/`nixos-rebuild switch`/`nix-shell`.

Although there are several existing ways to achieve this:

* cachix's [watch-exec and watch-store](https://docs.cachix.org/pushing)
* nix-build's [post-build-hook](https://nixos.org/manual/nix/stable/advanced-topics/post-build-hook)

However, the granularity of these methods is coarse; they push all packages to cachix.
Is there a way to allow users to control which packages are pushed?

## Conclusion First

Use **hooks** to push the selected packages to cachix:

| Scenario      | Hook                       | Example                                                                                                            |
|---------------|----------------------------|--------------------------------------------------------------------------------------------------------------------|
| home-manager  | `home.activation`          | [modules/cachix.nix](../../../modules/cachix.nix.md), [usr/modules/cachix.nix](../../../usr/modules/cachix.nix.md) |
| nixos-rebuild | `system.activationScripts` | [modules/cachix.nix](../../../modules/cachix.nix.md), [sys/modules/cachix.nix](../../../sys/modules/cachix.nix.md) |
| nix-shell     | `shellHook`                | [openc910/shell.nix](https://github.com/xieby1/openc910/blob/main/shell.nix)                                       |

---

## My Explorations

**Possible solutions**:
Add a wrapper called `cachixPackages`, which recives the packages to be pushed and cachix information.
This `cachixPackages` is a dummy package whose build stages will push the packages to cachix.
However, normal nix packages are not allowed network access during building.
To tackle this, like how fetch* series functions are implemented, the [fixed-output derivation](https://nixos.org/manual/nix/stable/language/advanced-attributes#adv-attr-outputHash) can be utilized to allow network access.

However, the above method seems not work as below,
because cachix needs accesses to some resources beyond nix-build process (such as nix-build's sandbox).

```bash
nix-build test.nix
...
cachix: CppStdException e "\ESC[31;1merror:\ESC[0m creating directory '\ESC[35;1m/nix/var\ESC[0m': \ESC[35;1mPermission denied\ESC[0m"(Just "nix::SysError")
result 1
...
```

Even though I disable the nix-build sandbox by using `--no-sandbox`,
the cachix still does not satisfy as below.

```bash
$ nix-build test.nix --no-sandbox
...
cachix: CppStdException e "\ESC[31;1merror:\ESC[0m cannot open connection to remote store '\ESC[35;1mdaemon\ESC[0m': \ESC[35;1m\ESC[31;1merror:\ESC[0m reading from file: \ESC[35;1mConnection reset by peer\ESC[0m\ESC[0m"(Just "nix::Error")
...
```

If you curious about my demo of `cachixPackages` and its test,
see [cachix-package.nix](./cachix-package.nix.md) and [test.nix](./test.nix.md).
