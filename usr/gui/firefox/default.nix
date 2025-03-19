#MC # firefox configurations
{ config, pkgs, stdenv, lib, ... }:
{
  imports = [
    ./apps
  ];
  home.packages = [
    # only with this package in home.packages, the installed PWAs will show up in gnome applications
    pkgs.firefoxpwa
  ];
  programs.firefox = {
    enable = true;
    # If state version ≥ 19.09 then this should be a wrapped Firefox
    package = (pkgs.firefox.override {
      nativeMessagingHosts = [
        pkgs.firefoxpwa
      ];
    }).overrideAttrs (old: {
      desktopItem = old.desktopItem.override {
        exec = "env MOZ_USE_XINPUT2=1 firefox --name firefox %U";
      };
    });
    profiles.xieby1 = {
      # id is default 0, thus this profile is default
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        # 😾😾😾 Chinese users cannot use ad block extensions
        # https://discourse.mozilla.org/t/chinese-users-cant-use-ad-blocker-extensions/94823
        ublock-origin
        pwas-for-firefox
      ];
      settings = {
        # Automatically enable extensions
        "extensions.autoDisableScopes" = 0;
        # Disable `alt` key of toggling menu bar
        "ui.key.menuAccessKeyFocuses" = false;
        "ui.key.menuAccessKey" = -1; # original number 18
        # enable userChrome.css
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
      userChrome = ''
        /* [Disabling the mouseover to reveal the address/toolbar while in fullscreen - old method doesn't work](https://support.mozilla.org/en-US/questions/1324666) */
        /* [prevent firefox from showing the address bar in fullscreen mode](https://support.mozilla.org/en-US/questions/1323320) */
        *|div#fullscr-toggler {display:none!important;}
      '';
    };
  };
}
