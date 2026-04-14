## `pkgs.callPackage` vs `pkgs.<lua>.pkgs.callPackage`

- **Regular Lua modules** (no pkgs dependencies): use `pkgs.<lua>.pkgs.callPackage` from `pkgs/development/lua-modules/generated-packages.nix`

- **Lua modules depending on pkgs packages**: use `pkgs/top-level/lua-packages.nix`

  The `callPackage` inherited here is still `callPackage` (from pkgs), for these reasons:

  1. In `pkgs/development/interpreters/lua-5/default.nix`:
     ```nix
     luaPackagesFun = callPackage ../../../top-level/lua-packages.nix {
       lua = self;
     };
     ```
     Here `callPackage` refers to `pkgs.callPackage`.

  2. `luaPackagesFun` is then passed to:
     ```nix
     makeScopeWithSplicing' {
       inherit otherSplices;
       f = lib.extends extensions luaPackagesFun;
     }
     ```

  ⚠️ **Caution**: The `makeScopeWithSplicing'` used here comes from `pkgs/top-level/splice.nix` — it already includes `pkgs.newScope` and only accepts a single attrset `{otherSplices, f, ...}`.

  This is easy to confuse with `lib/customisation.nix`'s `makeScopeWithSplicing'`, which accepts **two** attr parameters.

  Therefore, Lua's `makeScopeWithSplicing'` call **extends** the original pkgs scope.
