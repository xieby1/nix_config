{ pkgs, config, ... }: {
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
    pi-mcp-json = {
      target = ".pi/agent/mcp.json";
      # TODO: symlink real ~/.forge/.mcp.json
      inherit (config.home.file.".forge/.mcp.json") source;
    };
    agents_md = {
      target = ".pi/agent/AGENTS.md";
      # TODO: symlink real ~/.forge/AGENTS.md
      inherit (config.home.file.forge_agents_md) source;
    };
  };
}
