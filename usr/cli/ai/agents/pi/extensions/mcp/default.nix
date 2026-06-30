{ pkgs, ... }: {
  home.file = {
    ".pi/agent/extensions/pi-mcp-adapter" = {
      source = pkgs.buildNpmPackage {
        name = "pi-mcp-adapter";
        src = pkgs.npinsed.ai.pi.mcp-adapter;
        patches = [ ./status-color.patch ];
        postPatch = ''
          cp ${./package-lock.json} package-lock.json
        '';
        # npm lockfile v3 delegates to shrinkwrap → duplicate cache keys; writable cache is required.
        makeCacheWritable = true;
        npmDepsHash = "sha256-96o9+G2axISRcKUOp2ZGX8KcaH77R8+iAi0keCgz8xg=";
        dontNpmBuild = true;
        npmRebuildFlags = [ "--ignore-scripts" ];
      } + /lib/node_modules/pi-mcp-adapter;
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
