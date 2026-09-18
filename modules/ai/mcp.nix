{ pkgs, ... }: {
  # TODO: Precisely define the type
  # option = {...}
  config.ai.mcp = {
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
}
