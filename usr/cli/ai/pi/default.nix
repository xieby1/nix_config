{ pkgs, config, lib, ... }: let
  pi-coding-agent = pkgs.pkgsu.pi-coding-agent.overrideAttrs (final: prev: {
    # pi-coding-agent will check the version in check phase. The prefix "v" should be removed.
    # E.g.: "v0.67.3" => "0.67.3"
    version = pkgs.lib.removePrefix "v" final.src.version;
    src = pkgs.npinsed.ai.pi-mono;
    npmDepsHash = "sha256-3xFxY0iKiwjM0psijzdSqed5UOjIAOyWPwQ15fqfc4I=";
    npmDeps = pkgs.fetchNpmDeps {
      src = final.src;
      name = "pi-mono-${final.version}-npm-deps";
      hash = final.npmDepsHash;
    };
  });
in {
  home.packages = [
    pi-coding-agent
    (pkgs.callPackage ./pi-acp.nix {})
  ];
  cachix_packages = [pi-coding-agent];
  home.file = let
    gen-home-file-entry = args: {
      name = "pi-${args.catwalk-provider.id}";
      value = {
        target = ".pi/agent/extensions/${args.catwalk-provider.id}.ts";
        source = pkgs.callPackage ./provider.ts args;
      };
    };
  in lib.listToAttrs [
    (gen-home-file-entry {catwalk-provider=config.ai.minimax-china; api="anthropic-messages";})
    (gen-home-file-entry {catwalk-provider=config.ai.aliyun; api="openai-completions"; model-extra.compat.supportsDeveloperRole=false;})
    (gen-home-file-entry {catwalk-provider=config.ai.deepseek; api="openai-completions";})
    (gen-home-file-entry {catwalk-provider=config.ai.ollama; api="openai-completions";})
  ];
  yq-merge.".pi/agent/settings.json" = { generator = builtins.toJSON; expr = {
    defaultProvider = config.ai.minimax-china.id;
    defaultModel = config.ai.minimax-china.default_large_model_id;
  };};
}
