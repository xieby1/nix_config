{ ... }: {
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      inline_height = 0;
      scroll_exits = false;
      enter_accept = true;
    };
    flags = [ "--disable-up-arrow" ];
  };
}
