{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableVteIntegration = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      # https://unix.stackexchange.com/questions/58870/ctrl-left-right-arrow-keys-issue
      bindkey -M viins  "^[[1;5C" forward-word
      bindkey -M viins  "^[[1;5D" backward-word
      bindkey -M visual "^[[1;5C" forward-word
      bindkey -M visual "^[[1;5D" backward-word
      bindkey -M vicmd  "^[[1;5C" forward-word
      bindkey -M vicmd  "^[[1;5D" backward-word
      bindkey -M viopp  "^[[1;5C" forward-word
      bindkey -M viopp  "^[[1;5D" backward-word

      # source my zshrc
      if [[ -f ~/Gist/Config/zshrc ]]; then
        source ~/Gist/Config/zshrc
      fi
    '';
    plugins = [{
      name = "vi-mode";
      src = pkgs.zsh-vi-mode;
      file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
    }];
  };
}
