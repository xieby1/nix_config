{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableVteIntegration = true;
    plugins = [{
      name = "vi-mode";
      src = pkgs.zsh-vi-mode;
      file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
    }];
  };
}
