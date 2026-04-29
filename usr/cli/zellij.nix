{ ... }: {
  programs.zellij = {
    enable = true;
    layouts.simple.layout._children = [{
      pane = {
        _props = {
          size = 1;
          borderless = true;
        };
        plugin = {
          location = "tab-bar";
        };
      };
    }{
      pane = {};
    }];
    settings = {
      theme = "everforest-dark";
      pane_frames = false;
      simplified_ui = true;
      default_layout = "simple";
      # ui = {
      #   pane_frames = {
      #     hide_session_name = true;
      #   };
      # };
      keybinds = {
        normal._children = [
          {bind = {_args=["Ctrl Shift t"]; NewTab={};};}
          {bind = {_args=["Ctrl Shift Left"]; GoToPreviousTab={};};}
          {bind = {_args=["Ctrl Shift Right"]; GoToNextTab={};};}
        ];
      };
    };
  };
}
