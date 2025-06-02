{ pkgs, lib, ... }: let
  smart-toc = pkgs.nur.repos.rycee.firefox-addons.buildFirefoxXpiAddon {
    pname = "smart-toc";
    version = "0.11.25";
    addonId = "{40289693-01fe-4740-91ae-07344bf5b09b}";
    url = "https://addons.mozilla.org/firefox/downloads/file/4485577/smart_toc-0.11.25.xpi";
    sha256 = "17jpqy2qs3qc1m9l4kbqw14m5bkwfzb253wpf1x1b5p9q6sap8w8";
    meta = with lib; {
      mozPermissions = [
        "activeTab"
        "scripting"
        "storage"
        "tabs"
        "*://*/*"
        "file:///*"
      ];
      platforms = platforms.all;
    };
  };
in {
  programs.firefox = {
    profiles.xieby1 = {
      extensions = [ smart-toc ];
    };
  };
  firefox-extensions.xieby1 = {
    extension-settings = {
      commands = {
        toggle = {precedenceList = [{
          id = smart-toc.addonId;
          installDate = 0;
          value = { shortcut = "Alt+E"; };
          enabled = true;
        }];};
      };
    };
  };
}
