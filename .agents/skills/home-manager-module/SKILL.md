---
name: home-manager-module
description: Write home-manager modules with options, config, and tests. Use when creating or modifying NixOS/home-manager modules, defining custom options, or generating test.nix files.
---

# Writing Home-Manager Modules

## File Structure

A home-manager module lives in a directory with:

```
module-name/
├── default.nix   # Module definition (options + config)
├── test.nix      # Tests using pkgs.lib.runTests
```

## Module Template

```nix
{ config, pkgs, lib, ... }:
let
  cfg = config.<optionPath>;
in {
  options.<optionPath> = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        myField = lib.mkOption {
          type = lib.types.str;
          description = "...";
        };
        optionalField = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "...";
        };
      };
    });
    default = [];
    description = "...";
  };

  config = lib.mkIf (cfg != []) {
    # Transform cfg into actual home-manager config
  };
}
```

## Test Template

Tests use `nix eval -f test.nix` — success when output is `[ ]` (empty list).

```nix
let
  pkgs = import <nixpkgs> {};
  hm = import <home-manager/modules> {
    inherit pkgs;
    configuration = {
      imports = [./.];
      home = { stateVersion = "25.11"; username = "dummy"; homeDirectory = "/dummy"; };
      # Set module options here
    };
  };
in pkgs.lib.runTests {
  test-name = {
    expr = <expression>;
    expected = <expected value>;
  };
}
```

Run tests with: `nix eval -f test.nix | tee /dev/tty | grep -q '\[ \]'`

## Common Patterns

- Use `lib.filterAttrs (_: v: v != null)` to drop unset optional fields before serialization
- Use `lib.types.either lib.types.str (lib.types.listOf lib.types.str)` for fields accepting one or many strings
- Use `lib.mkIf` to conditionally apply config only when the option is non-empty
- Reference example module at `~/.config/nixpkgs/usr/modules/yq-merge/`

## References

- `nixpkgs` or `pkgs` source code: `~/.config/npins/nixpkgs/`
- `lib` source code: `~/.config/npins/nixpkgs/lib/`
- `home-manager` source code: `~/.config/npins/home-manager/`
