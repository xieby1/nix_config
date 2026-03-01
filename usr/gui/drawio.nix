{ pkgs, ... }: {
  home.packages = [
    pkgs.drawio
  ];
  xdg.mime.types = {
    drawio = {
      name = "draw-io";
      type = "text/draw-io";
      pattern = "*.drawio";
      defaultApp = "drawio.desktop";
    };
  };
  programs.neovim = {
    extraConfig = ''
      augroup filetype
        au! BufRead,BufNewFile *.drawio set filetype=xml
      augroup END
    '';
  };
}
