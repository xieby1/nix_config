{ pkgs, lib, ... }: {
  yq-merge.".config/goose/config.yaml" = {
    generator = builtins.toJSON;
    yqExtraArgs = "-P";
    expr = {
      # TODO: reduce MCP config duplication in all agents
      extensions = {
        ddgs = {
          enabled = true;
          type = "stdio";
          name = "ddgs";
          cmd = ''${
            pkgs.pkgsu.python3Packages.ddgs.overridePythonAttrs (old: {
              dependencies = old.dependencies
                ++ old.optional-dependencies.mcp
                ++ old.optional-dependencies.api;
            })
          }/bin/ddgs'';
          args = ["mcp"];
        };
        github = {
          enabled = true;
          type = "stdio";
          name = "github";
          cmd = ''${pkgs.github-mcp-server}/bin/github-mcp-server'';
          args = ["stdio"];
          envs = { GITHUB_PERSONAL_ACCESS_TOKEN = lib.trim (builtins.readFile ~/Gist/Vault/AI/github-mcp-server-all-repos-daily.txt);};
        };
      };
    };
  };
}
