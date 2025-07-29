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
    ./singleton_web_apps.nix
    ./rofi.nix
    ./xcolor.nix
    ./wsl.nix
    ./drawio.nix
  ];

config = lib.mkIf config.isGui {
  home.packages = with pkgs; [
    libnotify
    # browser
    # dont ask me for keyring chromium-like browsers!
    (chromium.override {commandLineArgs="--password-store=basic";})
  ] ++ [
    # network
  ] ++ pkgs.lib.optionals (builtins.currentSystem=="x86_64-linux") [
    feishu
    (wechat-uos.override {
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
    # telegram desktop not provide aarch64 prebuilt
    tdesktop
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
    # pkgs.pkgsu.deskflow
    barrier
    keepassxc
    # entertainment
    antimicrox
  ];

  # home.file.autostart_deskflow = {
  #   source = "${pkgs.pkgsu.deskflow}/share/applications/org.deskflow.deskflow.desktop";
  #   target = ".config/autostart/org.deskflow.deskflow.desktop";
  # };
  # use barrier due to its support of hotkey toggle screen!
  #   see: https://github.com/deskflow/deskflow/issues/8006
  home.file.autostart_barrier = {
    source = "${pkgs.barrier}/share/applications/barrier.desktop";
    target = ".config/autostart/barrier.desktop";
  };
};}
