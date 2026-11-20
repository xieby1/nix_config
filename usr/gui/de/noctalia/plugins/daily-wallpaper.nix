{ lib, ... }: {
  programs.noctalia.settings = {
    bar.default.start = lib.mkBefore ["daily-wallpaper"];
    plugins = {
      enabled = [
        "nzlov/daily-wallpaper"
      ];
    };
    widget.daily-wallpaper = {
      type = "nzlov/daily-wallpaper:widget";
      show_text = false;
    };
  };
}
