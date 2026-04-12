{ pkgs, config, lib, ... }: let
  gen-home-file-entry = catwalk-provider: api: {
    name = "pi-${catwalk-provider.id}";
    value = {
      target = ".pi/agent/extensions/${catwalk-provider.id}.ts";
      source = pkgs.callPackage ./provider.ts { inherit lib catwalk-provider api; };
    };
  };
in {
  home.packages = [
    pkgs.pkgsu.pi-coding-agent
  ];
  home.file = lib.listToAttrs [
    (gen-home-file-entry config.ai.minimax-china "anthropic-messages")
    (gen-home-file-entry config.ai.deepseek "openai-completions")
    (gen-home-file-entry config.ai.ollama "openai-completions")
  ];
  yq-merge.".pi/agent/settings.json".text = builtins.toJSON {
    defaultProvider = config.ai.minimax-china.id;
    defaultModel = config.ai.minimax-china.default_large_model_id;
  };
}
