{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableVteIntegration = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    completionInit = ''
      # Load the zsh/complist module, which provides colored completion listings,
      # scrolling through long lists, and an alternative menu selection style.
      # According to zshall(1), this should be done before compinit so that the
      # menu-select widget is properly re-defined by the completion system.
      zmodload zsh/complist

      # Initialize the programmable completion system (compinit).
      # This re-defines all completion widgets to use the smart, context-aware system.
      autoload -U compinit && compinit

      # Configure completion colors via the list-colors style.
      # When using compinit, ZLS_COLORS should not be set directly because the
      # completion system controls colors itself. Instead, we use zstyle with the
      # same colon-separated format as GNU ls. The (s.:.) flag splits LS_COLORS
      # by colons so each name=value pair is passed as a separate argument.
      zstyle ':completion:*:default' list-colors ''${(s.:.)LS_COLORS}
    '';
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
