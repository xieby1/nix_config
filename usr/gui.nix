{ config, pkgs, stdenv, lib, ... }:
let
  xelfviewer = pkgs.callPackage ./gui/xelfviewer.nix {};
  myxdot = pkgs.symlinkJoin {
    name = "myxdot";
    paths = [
      # TODO: xdot gobject-introspection dependency broken
      #   refers to https://github.com/NixOS/nixpkgs/pull/206186
      (pkgs.xdot.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs ++ [pkgs.gobject-introspection];
      }))
      (pkgs.makeDesktopItem {
        name = "xdot";
        desktopName = "xdot";
        exec = "xdot %U";
  })];};
  my-firefox = pkgs.runCommand "firefox-pinch" {} ''
    mkdir -p $out
    ${pkgs.xorg.lndir}/bin/lndir -silent ${pkgs.firefox} $out
    path=share/applications/firefox.desktop
    rm $out/$path
    sed 's/Exec=/Exec=env MOZ_USE_XINPUT2=1 /' ${pkgs.firefox}/$path > $out/$path
  '';
in
{
  imports = [
    ./gui/mime.nix
    ./gui/kdeconnect.nix
  ] ++ (if (builtins.getEnv "WSL_DISTRO_NAME")=="" then [
    ./gui/gnome.nix
    ./gui/terminal.nix
    ./gui/singleton_web_apps.nix
    ./gui/rofi.nix
  ] else [{ # install fonts for WSL
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
    ];
  }]);

  home.packages = with pkgs; [
    libnotify
    # browser
  ] ++ pkgs.lib.optionals (builtins.currentSystem=="x86_64-linux") [
    google-chrome
    microsoft-edge
  ] ++ [
    my-firefox
    # network
  ] ++ pkgs.lib.optionals (builtins.currentSystem=="x86_64-linux") [
    rustdesk
    feishu
    (wechat-uos.override {
      buildFHSEnv = args: buildFHSEnv (args // {
        # bubble wrap wechat-uos's home directory
        extraBwrapArgs = [
          "--bind ${config.home.homeDirectory}/.local/share/wechat-uos /home"
          "--chdir /home"
        ];
      });
      uosLicense = fetchurl {
        url = "https://github.com/xddxdd/nur-packages/raw/master/pkgs/uncategorized/wechat-uos/license.tar.gz";
        sha256 = "0sdx5mdybx4y489dhhc8505mjfajscggxvymlcpqzdd5q5wh0xjk";
      };
    })
    # wine weixin waste too much memory, more than 4GB!!!
    #(import ./gui/weixin.nix {})
    nur.repos.linyinfeng.wemeet
    nur.repos.xddxdd.dingtalk
    # telegram desktop not provide aarch64 prebuilt
    tdesktop
  ] ++ [
    transmission-gtk
    # text
    #wpsoffice
    libreoffice
    meld
    # TODO: use this after switching to wayland
    #wl-clipboard
    textsnatcher
    # draw
    drawio
    #aseprite-unfree
    inkscape
    gimp
    # viewer
    myxdot
  ] ++ pkgs.lib.optionals (builtins.currentSystem=="x86_64-linux") [
    imhex
    xelfviewer
  ] ++ [
    vlc
  ] ++ pkgs.lib.optionals (builtins.currentSystem=="x86_64-linux") [
    ghidra
  ] ++ [
    # management
  ] ++ pkgs.lib.optionals (builtins.currentSystem=="x86_64-linux") [
    zotero
  ] ++ [
    barrier
    # entertainment
    antimicrox
    # music
  ] ++ pkgs.lib.optionals (builtins.currentSystem=="x86_64-linux") [
    spotify
  ];

  cachix_packages = lib.optional (builtins.currentSystem=="x86_64-linux") pkgs.rustdesk;

  xdg.mime.types = {
    dot = {
      name = "graphviz-dot";
      type = "text/graphviz-dot";
      pattern = "*.dot";
      defaultApp = "xdot.desktop";
    };
    drawio = {
      name = "draw-io";
      type = "text/draw-io";
      pattern = "*.drawio";
      defaultApp = "drawio.desktop";
    };
  };

  home.file.autostart_barrier = {
    source = "${pkgs.barrier}/share/applications/barrier.desktop";
    target = ".config/autostart/barrier.desktop";
  };
}
