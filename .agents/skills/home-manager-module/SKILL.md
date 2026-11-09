---
name: home-manager-module
description: Write home-manager modules with options, config, and tests. Use when creating or modifying NixOS/home-manager modules, defining custom options, generating test.nix files, or applying this repo's localArgs/globalArgs, importApply, and colocated npins conventions.
---

# Writing Home-Manager Modules

## File Structure

A home-manager module lives in a directory with:

```
module-name/
├── default.nix   # Module definition (options + config)
├── test.nix      # Tests using pkgs.lib.runTests
```

## localArgs and globalArgs (Repository Convention)

Separate explicit parent-to-child dependencies from the shared module-evaluation environment.
This uses Nixpkgs' existing `lib.modules.importApply` pattern for lexical dependency injection; `localArgs` and `globalArgs` are repository terminology, not Nix keywords.

- **localArgs**: the first argument, supplied explicitly by the importing parent. Use it for child-specific dependencies and composition choices such as `src`, `nixdSrc`, and `enableExtendedCLI`.
- **globalArgs**: the argument supplied by the module evaluator to the returned module function. It includes normal module arguments such as `lib`, `pkgs`, and `config`, plus custom arguments from `specialArgs` or `_module.args`, such as `npinsFun`. Request `_module.args` entries by name in the parameter pattern; `...` alone does not collect them.

```nix
# child.nix
{ src }: # localArgs
{ lib, pkgs, config, ... }: # globalArgs
{
  home.file.".config/example".source = src.outPath;
}
```

The parent applies the local arguments with `lib.modules.importApply ./child.nix { src = sources.example; }` in its `imports` list.
The returned function remains an ordinary module, so the evaluator still injects its normal arguments.
Plain modules without local dependencies do not need an extra function header.

### Rules

- Pass only what a child needs. A dispatcher may receive a selected source set; leaf modules normally receive individual sources or packages rather than the entire application's pins or package set.
- Forward local arguments explicitly at each required import edge; there is no automatic parent-to-child inheritance.
- Set policy defaults once at the entry point. Children require the arguments forwarded to them rather than silently supplying another default.
- Keep application pins in a colocated `sources.json`, load them at their owning module, and keep only generic facilities such as `npinsFun` shared. Provide shared arguments from a module imported by every relevant device profile.
- Use `npins --lock-file path/to/sources.json` for colocated pins. Directory-mode `init`/`upgrade` can overwrite the application's `default.nix`.
- Select optional import subtrees with a flag independent of the current configuration, such as the explicitly supplied `enableExtendedCLI`. Do not derive the import list from the current evaluation's `config` or `_module.args`. Local arguments can still hold lazy values; their name describes who supplies them, not when every value is evaluated.
- Keep mergeable, user-overridable settings as module options. Local arguments are dependencies or deliberate composition choices, not a replacement for all options.
- “Global” means within one module evaluation, not across separate evaluations or submodule scopes.
- `importApply` preserves source locations but does not automatically provide path-based deduplication or `disabledModules` identity. Avoid duplicate applications; if identity is needed, choose an explicit key that distinguishes differently parameterized instances.

### Upstream Precedent

- [Nixpkgs `importApply` documentation](https://github.com/NixOS/nixpkgs/blob/master/lib/modules.nix): documents the extra argument followed by a normal module function, including the module-identity caveat.
- [Flake-parts: Define a Module in a Separate File](https://flake.parts/define-module-in-separate-file.html): demonstrates the same two-stage structure and the alternative of exposing configuration through options.
- [Nixpkgs PR #230588](https://github.com/NixOS/nixpkgs/pull/230588): discusses lexical dependency injection versus parameterized module generation, and the trade-off with options. This convention adopts the supported mechanism, not a claim of community-wide agreement on these names or rules.

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
in pkgs.lib.runTests {
  test-name = {
    expr = <expression>;
    expected = <expected value>;
  };
}
```

Run tests with: `nix eval -f test.nix`

## Testing Function-Style Modules

Modules that are functions (not traditional home-manager modules with options/config) can still be tested:

```nix
let
  pkgs = import <nixpkgs> {};
in pkgs.lib.runTests {
  test-module = pkgs.lib.testAllTrue [
    (pkgs.lib.hasInfix "expected-string" content)
    (pkgs.lib.hasInfix "another-string" content)
  ];
  test-assertion = {
    expr = builtins.tryEval (import ./default.nix { invalid-param = true; });
    expected = { success = false; value = false; };
  };
}
```

Where `content` is the output of the function, often obtained via `builtins.readFile`.

## Common Patterns

- Use `pkgs.lib.filterAttrs (_: v: v != null)` to drop unset optional fields before serialization
- Use `pkgs.lib.types.either pkgs.lib.types.str (pkgs.lib.types.listOf pkgs.lib.types.str)` for fields accepting one or many strings
- Use `pkgs.lib.mkIf` to conditionally apply config only when the option is non-empty
- Use `pkgs.lib.testAllTrue` instead of manually comparing attrsets for simple boolean checks
- Use `pkgs.lib.hasInfix` to check if a string contains a substring
- Use `builtins.tryEval` to test code that should fail (e.g., assertion failures)
- Declare variables in the narrowest scope needed — avoid top-level declarations when only used in one test
- Reference example module at `~/.config/nixpkgs/usr/modules/yq-merge/`

## References

- `nixpkgs` or `pkgs` source code: `~/.config/npins/nixpkgs/`
- `lib` source code: `~/.config/npins/nixpkgs/lib/`
- `home-manager` source code: `~/.config/npins/home-manager/`
