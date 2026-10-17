{ pkgs, ... }: {
  # TODO: Precisely define the type
  # option = {...}
  config.ai.mcp = {
    ddgs = {
      # nixpkgs' stock ddgs (9.14.2) still uses `mcp.server.fastmcp`, matching
      # the vendored python mcp 1.26.0. ddgs >= 9.15 switched to
      # `mcp.server.mcpserver` (mcp 2.x), so stay on the channel's version.
      command = ''${
        pkgs.python3Packages.ddgs.overridePythonAttrs (old: {
          dependencies = old.dependencies
            ++ old.optional-dependencies.mcp
            ++ old.optional-dependencies.api;
        })
      }/bin/ddgs'';
      args = ["mcp"];
    };
  };
}
