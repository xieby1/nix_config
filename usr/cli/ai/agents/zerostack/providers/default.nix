{ config, ... }: {
  yq-merge.".config/zerostack/config.json" = {
    generator = builtins.toJSON;
    yqExtraArgs = "-P";
    expr = let
      # TODO: move to ai module
      default-provider = config.ai.jw-codex;
    in {
      provider = default-provider.id;
      model = default-provider.default_large_model_id;
      # TODO: zerostack only support global context_window
      context_window = 256 * 1000;
    };
  };

  imports = [
    (import ./catwalk-to-custom-provider.nix config.ai.kimi)
    (import ./catwalk-to-custom-provider.nix config.ai.minimax-china)
    (import ./catwalk-to-custom-provider.nix config.ai.jw-codex)
  ];
}
