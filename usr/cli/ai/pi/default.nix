{ pkgs, config, lib, ... }: {
  home.packages = [
    pkgs.pkgsu.pi-coding-agent
  ];
  home.file.pi-minimax-cn = {
    target = ".pi/agent/extensions/minimax-cn.ts";
    text = import ./provider.ts.nix {
      inherit lib;
      name = "minimax-cn";
      catwalk-provider = config.ai.minimax-china;
      api = "anthropic-messages";
    };
  };
  home.file.pi-deepseek = {
    target = ".pi/agent/extensions/deepseek.ts";
    text = import ./provider.ts.nix {
      inherit lib;
      catwalk-provider = config.ai.deepseek;
      api = "openai-completions";
    };
  };
  home.file.pi-ollama = {
    target = ".pi/agent/extensions/ollama.ts";
    text = import ./provider.ts.nix {
      inherit lib;
      catwalk-provider = config.ai.ollama;
      api = "openai-completions";
    };
  };
}
