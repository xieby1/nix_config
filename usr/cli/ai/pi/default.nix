{ pkgs, config, lib, ... }: let
  gen-home-file-entry = catwalk-provider: api: {
    name = "pi-${catwalk-provider.id}";
    value = {
      target = ".pi/agent/extensions/${catwalk-provider.id}.ts";
      text = import ./provider.ts.nix { inherit lib catwalk-provider api; };
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
  };
}
