{ ... }: {
  imports = [
    ./bash-zsh-forward.nix
  ];
  programs.zsh = {
    enable = true;
  };
}
