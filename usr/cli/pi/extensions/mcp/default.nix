{ pkgs, lib, config, ... }:
let
  # Pi's extension loader injects its own copies of pi-ai, pi-tui, and typebox
  # via jiti aliases, so the extension doesn't need its own copies (~130 MiB saved).
  slimSrc = pkgs.applyPatches {
    name = "pi-mcp-adapter-slim";
    src = pkgs.npinsed.ai.pi.mcp-adapter;
    nativeBuildInputs = [ pkgs.jq ];
    patches = [
      ./status-color.patch
    ];
    postPatch = ''
      jq 'del(.dependencies["@earendil-works/pi-ai","@earendil-works/pi-tui","typebox"]) | del(.devDependencies) | del(.scripts.prepare)' \
        package.json > package.json.tmp && mv package.json.tmp package.json
      cp ${./package-lock.json} package-lock.json
    '';
  };
in
{
  home.file = {
    ".pi/agent/extensions/pi-mcp-adapter" = {
      source = pkgs.buildNpmPackage {
        name = "pi-mcp-adapter";
        src = slimSrc;
        npmDepsHash = "sha256-c/VdxR9f7HljsLNu4kVa0JxvvphEQ7wmAxaz2Iq/Eio=";
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
