{ pkgs, ... }: let
  sidebery = pkgs.nur.repos.rycee.firefox-addons.sidebery;
in {
  programs.firefox = {
    profiles.xieby1 = {
      extensions.packages = [ sidebery ];
      # transparent floating sidebar
      # Why not use it?
      # Because: I tried two ways to adjust the height of sidebar dynamically, but all failed:
      # * user.js cannot inject js code
      # * css counter cannot used in height
      #
      #settings = {
      #  "browser.tabs.allow_transparent_browser" = true;
      #};
      #userChrome = ''
      #  #sidebar-box {
      #    height: 90%;
      #    top: 5%;
      #    right: 0;
      #    position: absolute;
      #    z-index: 99;
      #  }
      #  #browser,
      #  tabbox#tabbrowser-tabbox,
      #  #tabbrowser-tabpanels,
      #  #sidebar-box,
      #  #sidebar,
      #  window#webextpanels-window {
      #    background-color: transparent !important;
      #    background-image: none !important;
      #  }
      #'';
      #userContent = ''
      #  @-moz-document regexp("^moz-extension://.*/sidebar/sidebar.html") {
      #    :root {
      #      background-color: transparent !important;
      #    }
      #    #root.root {
      #      --frame-bg: transparent !important;
      #      --toolbar-bg: black !important;
      #      --frame-el-bg: black !important;
      #    }
      #  }
      #'';
      settings = {
        "sidebar.position_start" = false; # sidebar on the right
      };
      userChrome = ''
        /* Completely Remove Firefox Tab Bar */
        /* https://bricep.net/completely-remove-firefox-tab-bar/ */
        #TabsToolbar { visibility: collapse !important; }

        #sidebar-header { display: none; }
        #sidebar-splitter { display: none; }
        #sidebar-box {
          width: 13vw !important;
          min-width: 8em !important;
          max-width: 15em !important;
          padding: 0 !important;
        }
      '';
    };
  };

  firefox-extensions.xieby1 = {
    extension-settings = {
      commands = {
        # toggle sidebery
        _execute_sidebar_action = { precedenceList = [{
           id = sidebery.addonId;
           installDate = 0;
           value = { shortcut = "F1"; };
           enabled = true;
        }];};
        search = { precedenceList = [{
          id = sidebery.addonId;
          installDate = 0;
          value = { shortcut = "F2"; };
          enabled = true;
        }];};
        up_shift = { precedenceList = [{
          id = sidebery.addonId;
          installDate = 0;
          value = { shortcut = "Alt+Shift+Left"; };
          enabled = true;
        }];};
        down_shift = { precedenceList = [{
          id = sidebery.addonId;
          installDate = 0;
          value = { shortcut = "Alt+Shift+Right"; };
          enabled = true;
        }];};
        rm_tab_on_panel = { precedenceList = [{
          id = sidebery.addonId;
          installDate = 0;
          value = { shortcut = "Alt+Shift+Delete"; };
          enabled = true;
        }];};
        switch_to_next_tab = { precedenceList = [{
          id = sidebery.addonId;
          installDate = 0;
          value = { shortcut = "Alt+Shift+Down"; };
          enabled = true;
        }];};
        switch_to_prev_tab = { precedenceList = [{
          id = sidebery.addonId;
          installDate = 0;
          value = { shortcut = "Alt+Shift+Up"; };
          enabled = true;
        }];};
      };
    };
  };
}
