#MC # firefox configurations
{ config, pkgs, stdenv, lib, ... }:
{
  imports = [
    ./apps
    ./extensions
  ];
  programs.firefox = {
    enable = true;
    # If state version ≥ 19.09 then this should be a wrapped Firefox
    package = pkgs.firefox.overrideAttrs (old: {
      # MOZ_USE_XINPUT2=1 allow more smooth (pixel-level) scroll and zoom
      buildCommand = old.buildCommand + ''
        mv $out/bin/firefox $out/bin/firefox-no-xinput2
        makeWrapper $out/bin/firefox-no-xinput2 $out/bin/firefox --set-default MOZ_USE_XINPUT2 1
      '';
    });
    profiles.xieby1 = {
      # id is default 0, thus this profile is default
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        # 😾😾😾 Chinese users cannot use ad block extensions
        # https://discourse.mozilla.org/t/chinese-users-cant-use-ad-blocker-extensions/94823
        ublock-origin
      ];
      settings = {
        # https://superuser.com/questions/1483037/making-firefox-fullscreen-like-without-actually-maximizing-the-window
        # the full screen hotkey/button will trigger fullscreen like normal, except it won't resize the window.
        "full-screen-api.ignore-widgets" = true;
        # Automatically enable extensions
        "extensions.autoDisableScopes" = 0;
        # Disable `alt` key of toggling menu bar
        "ui.key.menuAccessKeyFocuses" = false;
        "ui.key.menuAccessKey" = -1; # original number 18
        # enable userChrome.css
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
      userChrome =
      # [Disabling the mouseover to reveal the address/toolbar while in fullscreen - old method doesn't work](https://support.mozilla.org/en-US/questions/1324666)
      # [prevent firefox from showing the address bar in fullscreen mode](https://support.mozilla.org/en-US/questions/1323320)
      ''
        *|div#fullscr-toggler {display:none!important;}
      '';
    };
  };
}
