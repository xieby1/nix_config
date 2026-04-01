{ pkgs, config, lib, ... }: {
  home.packages = [
    pkgs.pkgsu.pi-coding-agent
  ];
  home.file.pi-minimax-cn = {
    target = ".pi/agent/extensions/minimax-cn.ts";
    text = import ./provider.nix {
      inherit lib;
      name = "minimax-cn";
      catwalk-provider = config.ai.minimax-china;
      api = "anthropic-messages";
    };
  };
  home.file.pi-deepseek = {
    target = ".pi/agent/extensions/deepseek.ts";
    text = import ./provider.nix {
      inherit lib;
      catwalk-provider = config.ai.deepseek;
      api = "openai-completions";
    };
  };
}
