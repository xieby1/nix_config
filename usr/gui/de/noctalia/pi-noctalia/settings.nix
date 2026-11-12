settings: settings // {
  "bar.default" = settings."bar.default" // {
    start = settings."bar.default".start ++ [ "pi-noctalia" ];
  };
  plugins = settings.plugins // {
    enabled = settings.plugins.enabled ++ [ "local/pi-noctalia" ];
  };
  "widget.pi-noctalia" = {
    type = "local/pi-noctalia:widget";
    max_visible = 3;
  };
}
