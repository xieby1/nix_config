# * hstr: not handle `~` correctly, always expand
# * atuin: often not record my command, do know why
#   * besides, the network sync is redundant for me
{ ... }: {
  programs.mcfly = {
    enable = true;
    enableBashIntegration = true;
    fuzzySearchFactor = 3;
    fzf.enable = true;
    keyScheme = "vim";
  };
  programs.bash.bashrcExtra = /*bash*/ ''
    export MCFLY_RESULTS_SORT=LAST_RUN
  '';
}
