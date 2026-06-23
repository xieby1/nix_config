{ pkgs, config, lib, ... }: {
  yq-merge.".forge/.mcp.json" = {
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
        github = {
          command = ''${pkgs.github-mcp-server}/bin/github-mcp-server'';
          args = ["stdio"];
          env = { GITHUB_PERSONAL_ACCESS_TOKEN = lib.trim (builtins.readFile "${config.home.homeDirectory}/Gist/Vault/AI/github-mcp-server-minimal.txt");};
        };
      };
    };
  };
}
