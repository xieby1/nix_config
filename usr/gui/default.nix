{ config, pkgs, stdenv, lib, ... }:
let
  xelfviewer = pkgs.callPackage ./xelfviewer.nix {};
in
{
  imports = [
    ./mime.nix
    ./kdeconnect.nix
    ./xdot.nix
    ./firefox
    ./warpd.nix
    ./rustdesk.nix
    ./gnome
    ./kitty
    ./singleton_apps.nix
    ./rofi.nix
    ./xcolor.nix
    ./wsl.nix
    ./drawio.nix
    ./flameshot.nix
    ./fcitx5
    ./niri
    ./plasma
  ];

config = lib.mkIf config.isGui {
  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "o" ''nohup xdg-open "$@" &> /dev/null &'')
    libnotify
    # browser
    # dont ask me for keyring chromium-like browsers!
    (chromium.override {commandLineArgs="--password-store=basic";})
  ] ++ [
    # network
  ] ++ pkgs.lib.optionals (builtins.currentSystem=="x86_64-linux") [
    feishu
    (pkgsu.wechat-uos.override {
      buildFHSEnv = args: buildFHSEnv (args // {
        # bubble wrap wechat-uos's home directory
        extraBwrapArgs = [
          "--bind ${config.home.homeDirectory}/.local/share/wechat-uos /home"
          "--chdir /home"
        ];
      });
    })
    # wine weixin waste too much memory, more than 4GB!!!
    #(import ./weixin.nix {})
    wemeet
    nur.repos.xddxdd.dingtalk
  ] ++ [
    transmission_4-gtk
    # text
    #wpsoffice
    libreoffice
    meld
    # TODO: use this after switching to wayland
    #wl-clipboard
    textsnatcher
    # draw
    #aseprite-unfree
    inkscape
    gimp
    # viewer
  ] ++ pkgs.lib.optionals (builtins.currentSystem=="x86_64-linux") [
    imhex
    xelfviewer
  ] ++ [
    vlc
    obsidian
  ] ++ pkgs.lib.optionals (builtins.currentSystem=="x86_64-linux") [
    ghidra
  ] ++ [
    # management
  ] ++ pkgs.lib.optionals (builtins.currentSystem=="x86_64-linux") [
    zotero
  ] ++ [
    input-leap
    keepassxc
    # entertainment
    antimicrox
  ];

  # deskflow vs input-leap
  # deskflow not support metakeys: window, alt-tab, alt-f4, ...
  home.file.autostart_input_leap = {
    source = "${pkgs.input-leap}/share/applications/io.github.input_leap.input-leap.desktop";
    target = ".config/autostart/input-leap.desktop";
  };
};}
