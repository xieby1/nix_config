{ pkgs, ... }: {
  home.file = {
    ".pi/agent/extensions/pi-mcp-adapter" = {
      source = pkgs.pkgspi.piExtensions.pi-mcp-adapter.overrideAttrs (old: {
        patches = (old.patches or []) ++ [
          ./status-color.patch
        ];
      });
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
