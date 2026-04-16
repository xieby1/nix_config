{ pkgs, config, lib, ... }: let
in {
  home.packages = [
    (pkgs.pkgsu.pi-coding-agent.overrideAttrs (final: prev: {
      # pi-coding-agent will check the version in check phase. The prefix "v" should be removed.
      # E.g.: "v0.67.3" => "0.67.3"
      version = pkgs.lib.removePrefix "v" final.src.version;
      src = (pkgs.npinsed{input=../npins/sources.json;}).pi-mono;
      npmDepsHash = "sha256-3xFxY0iKiwjM0psijzdSqed5UOjIAOyWPwQ15fqfc4I=";
      npmDeps = pkgs.fetchNpmDeps {
        src = final.src;
        name = "pi-mono-${final.version}-npm-deps";
        hash = final.npmDepsHash;
      };
    }))
    (pkgs.callPackage ./pi-acp.nix {})
  ];
  home.file = let
    gen-home-file-entry = catwalk-provider: api: {
      name = "pi-${catwalk-provider.id}";
      value = {
        target = ".pi/agent/extensions/${catwalk-provider.id}.ts";
        source = pkgs.callPackage ./provider.ts { inherit lib catwalk-provider api; };
      };
    };
  in lib.listToAttrs [
    (gen-home-file-entry config.ai.minimax-china "anthropic-messages")
    (gen-home-file-entry config.ai.deepseek "openai-completions")
    (gen-home-file-entry config.ai.ollama "openai-completions")
  ];
  yq-merge.".pi/agent/settings.json".text = builtins.toJSON {
    defaultProvider = config.ai.minimax-china.id;
    defaultModel = config.ai.minimax-china.default_large_model_id;
  };
}
