{ pkgs, config, lib, ... }: {
  home.file = let
    gen-home-file-entry = catwalk: {
      name = "pi-${catwalk.id}";
      value = {
        target = ".pi/agent/extensions/${catwalk.id}.ts";
        source = pkgs.callPackage ./provider.ts {} catwalk;
      };
    };
  in lib.listToAttrs [
    (gen-home-file-entry config.ai.minimax-china)
    (gen-home-file-entry config.ai.kimi)
    (gen-home-file-entry config.ai.deepseek)
  ];
  yq-merge.".pi/agent/settings.json" = { generator = builtins.toJSON; expr = {
    defaultProvider = config.ai.minimax-china.id;
    defaultModel = config.ai.minimax-china.default_large_model_id;
  };};
}
