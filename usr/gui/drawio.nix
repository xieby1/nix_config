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
}
