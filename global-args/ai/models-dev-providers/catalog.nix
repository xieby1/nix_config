{ pkgs, src }: let
  # Only the generator's runtime dependencies, pinned from upstream bun.lock.
  remeda = pkgs.fetchurl {
    url = "https://registry.npmjs.org/remeda/-/remeda-2.33.7.tgz";
    hash = "sha512-cXlyjevWx5AcslOUEETG4o8XYi9UkoCXcJmj7XhPFVbla+ITuOBxv6ijBrmbeg+ZhzmDThkNdO+iXKUfrJep1w==";
  };
  zod = pkgs.fetchurl {
    url = "https://registry.npmjs.org/zod/-/zod-3.24.2.tgz";
    hash = "sha512-lY7CDW43ECgW9u1TcT3IoXHflywfVqDYze4waEz812jR/bZ8FHDsl7pFQoSZTz5N+2NqRXs8GBwnAwo3ZNxqhQ==";
  };
in pkgs.runCommand "models-dev-api.json" {
  nativeBuildInputs = [ pkgs.bun pkgs.jq ];
} ''
  cp -r ${src} source
  chmod u+w source
  cd source
  mkdir -p node_modules/{remeda,zod}
  tar -xzf ${remeda} --strip-components=1 -C node_modules/remeda
  tar -xzf ${zod} --strip-components=1 -C node_modules/zod
  bun --eval '
    import { generateCatalog } from "./packages/core/src/generate.ts";
    import { filterProvidersByModelType } from "./packages/core/src/filter.ts";
    const { providers } = await generateCatalog(process.cwd());
    await Bun.write("api.json", JSON.stringify(filterProvidersByModelType(providers, "default")));
  '
  # Filesystem traversal order must not change the output hash.
  jq --sort-keys --compact-output . api.json > "$out"
''
