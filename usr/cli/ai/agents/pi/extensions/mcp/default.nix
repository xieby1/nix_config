{ pkgs, config, ... }: {
  home.file = {
    ".pi/agent/extensions/pi-mcp-adapter" = {
      source = pkgs.buildNpmPackage {
        name = "pi-mcp-adapter";
        src = pkgs.npinsed.ai.pi.mcp-adapter;
        patches = [
          ./status-color.patch
          ./package-lock-integrity.patch
        ];
        # npm lockfile v3 delegates to shrinkwrap → duplicate cache keys; writable cache is required.
        makeCacheWritable = true;
        npmDepsHash = "sha256-xIW2WTuVj6SeFGrJPEduzzVCT548i7tzlP5sq3ky/wI=";
        dontNpmBuild = true;
        npmRebuildFlags = [ "--ignore-scripts" ];
      } + /lib/node_modules/pi-mcp-adapter;
    };
  };

  yq-merge.".pi/agent/mcp.json" = {
    generator = builtins.toJSON;
    expr = {
      mcpServers = {
        ddgs = { inherit (config.ai.mcp.ddgs) command args; };
      };
    };
  };
}
