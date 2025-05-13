{ pkgs, ... }: {
  programs.firefox = {
    profiles.xieby1 = {
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        sidebery
      ];
      userChrome = ''
        /* Completely Remove Firefox Tab Bar */
        /* https://bricep.net/completely-remove-firefox-tab-bar/ */
        #TabsToolbar { visibility: collapse !important; }

        #sidebar-header { display: none; }
        #sidebar-splitter { display: none; }
        #sidebar-box {
          /* move sidebar-box to the right */
          order: 99 !important;

          width: 15vw !important;
          min-width: 8em !important;
          padding: 0 !important;
        }
      '';
    };
  };
}
