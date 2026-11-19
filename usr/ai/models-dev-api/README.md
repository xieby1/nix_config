# Models.dev API catalog

`sources.json` pins the upstream Models.dev Git source with npins.
`default.nix` runs upstream's `generateCatalog()` and default v1 filtering in a Nix sandbox, resolving TOML inheritance and schema translation.
Only the generator's runtime packages (`remeda` and `zod`) are fetched, using the exact versions and integrity hashes from the pinned `bun.lock`.
No install scripts or network requests run during generation.
The generated JSON lives in the Nix store, not this repository.

Reading the catalog during Nix evaluation uses import-from-derivation (IFD).
The first evaluation builds it; subsequent evaluations reuse the store result.
Pi filters specialized non-chat models at its converter boundary.
Prices are USD per million tokens; `limit.output` is a maximum, not a default generation budget.

Update from the repository root:

```bash
npins --lock-file global-args/ai/models-dev-api/sources.json update models-dev
nix-build --no-out-link -E '(import <nixpkgs> {}).callPackage ./global-args/ai/models-dev-api {}'
nix-instantiate --eval --strict global-args/ai/models-dev-api/test.nix
nix-instantiate --eval --strict usr/cli/basic/pi/providers/models-dev-to-custom-provider/test.nix
nix-instantiate --eval --strict usr/cli/basic/pi/extensions/pi-title/test.nix
home-manager build --no-out-link
```

When updating, compare the generator's dependencies in upstream `packages/core/package.json` and `bun.lock` with the package versions/hashes in `default.nix`.
Review generated model IDs, pricing and limits before committing.
