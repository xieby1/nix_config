{ pkgs, ... }: {
  home.file = {
    pi-mcp-adapter = {
      target = ".pi/agent/extensions/pi-mcp-adapter";
      source = pkgs.buildNpmPackage (finalAttrs: {
        name = "pi-mcp-adapter";
        src = pkgs.npinsed.ai.pi-mcp-adapter;
        npmDepsHash = "sha256-ml5sC0dUPpZU30tSNi48a0bP5SRUg2FtwR8nYRW4FhU=";
        dontNpmBuild = true;
      }) + /lib/node_modules/pi-mcp-adapter;
    };
  };

  yq-merge.".pi/agent/mcp.json" = {
    generator = builtins.toJSON;
    expr = {
      mcpServers = {
        ddgs = {
          command = ''${
            pkgs.pkgsu.python3Packages.ddgs.overridePythonAttrs (old: {
              dependencies = old.dependencies
                ++ old.optional-dependencies.mcp
                ++ old.optional-dependencies.api;
            })
          }/bin/ddgs'';
          args = ["mcp"];
        };
      };
    };
  };
}
