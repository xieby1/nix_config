{ pkgs, config, lib, ... }: {
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
    (gen-home-file-entry {catwalk-provider=config.ai.kimi; api="anthropic-messages";})
    (gen-home-file-entry {catwalk-provider=config.ai.aliyun; api="openai-completions"; model-extra.compat.supportsDeveloperRole=false;})
    (gen-home-file-entry {catwalk-provider=config.ai.deepseek; api="openai-completions";})
    (gen-home-file-entry {catwalk-provider=config.ai.ollama; api="openai-completions";})
  ];
  yq-merge.".pi/agent/settings.json" = { generator = builtins.toJSON; expr = {
    defaultProvider = config.ai.minimax-china.id;
    defaultModel = config.ai.minimax-china.default_large_model_id;
  };};
}
