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
        # - There are not nixpkgs/basic-memory/3rd-party nix package for basic-memory.
        # - No issues/discussions mention nix package.
        # - Using AI to package basic-memory does not works well.
        # So I use uvx here.
        basic-memory = {
          enabled = true;
          type = "stdio";
          name = "basic-memory";
          cmd = "${pkgs.uv}/bin/uvx";
          args = ["basic-memory" "mcp"];
          envs = {
            LD_LIBRARY_PATH = lib.makeLibraryPath [ pkgs.stdenv.cc.cc.lib ];
          };
        };
      };
    };
  };
}
