{ ... }: {
  yq-merge.".forge/.mcp.json" = {
    generator = builtins.toJSON;
    expr = {
      mcpServers = {
        vestige = {
          command = "${import ../../../mcp/vestige/package.nix}/bin/vestige-mcp";
        };
      };
    };
  };
  home.file.forge_agents_md = {
    target = ".forge/AGENTS.md";
    text = builtins.readFile (import ../../../mcp/vestige/agents_md.nix);
  };
}
