# TIPS (https://github.com/piroor/treestyletab/wiki/How-to-inspect-tree-of-tabs):
# How to start debugger?
# 1. Type about:debugging into the address bar and hit the Enter key.
# 2. Choose "This Firefox" at the left pane.
# 3. Find "Tree Style Tab" from the list and click the Inspect button.
# 4. Then a debugger tab is opened.
#
# How to inspect the sidebar?
# 1. Start the debugger for TST.
# 2. On the top-right corner of the debugger window, there are some buttons, so click the Select an iframe as the currently targeted document button.
# 3. Choose /sidebar/sidebar.html from the list.
#   3.1. If you are opening multiple browser windows with their sidebar, you'll see multiple entries in the list.
#   3.2. /sidebar/sidebar.html items are sorted by the order they are initialized. If you hope to inspect the sidebar in the first browser window, you should choose first /sidebar/sidebar.html item in the list.
# 4. Choose the Inspector tab.

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
  firefox-extensions.xieby1.browser-extension-data."${sidebery.addonId}" = {
    storage = {
      sidebarCSS = /*css*/ ''
        /* make vertical line more clear */
        /* original: --tabs-lvl-opacity: 0.16 */
        #root.root { --tabs-lvl-opacity: 0.8; }

        /* compact fav margin */
        .Tab[data-pin="false"] .fav {
          /* original: 0 var(--tabs-inner-gap)0 calc(var(--tabs-inner-gap) + 2px); */
          margin: 0;
        }

        /* white border for activated tab */
        #root.root { --tabs-activated-shadow: 0 0 0 1px white; }
        /* make sure the top tab shadow is not clipped */
        /* Why not using border?
           Because border will add size to the div, thus changing the layout.
           As a result, the vertical line is not aligned.
        */
        .AnimatedTabList { padding-top: 1px; }
      '';
    };
  };
}
