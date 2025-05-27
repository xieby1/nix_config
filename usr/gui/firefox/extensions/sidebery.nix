{ pkgs, ... }: {
  programs.firefox = {
    profiles.xieby1 = {
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        sidebery
      ];
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
          width: 15vw !important;
          min-width: 8em !important;
          padding: 0 !important;
        }
      '';
    };
  };
}
