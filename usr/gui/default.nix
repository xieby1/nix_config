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
    ./cheatsheet_edit.nix
    ./xcolor.nix
    ./wsl.nix
    ./drawio.nix
    ./flameshot.nix
    ./fcitx5
    # TODO: remove
    ./niri
    ./rofi.nix
    # ./plasma
    # ./hyprland
    ./dms
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
    (wechat-uos.override {
      buildFHSEnv = args: buildFHSEnv (args // {
        # bubble wrap wechat-uos's home directory
        extraBwrapArgs = ["--bind ${config.home.homeDirectory}/.local/share/wechat-uos /home"];
        chdirToPwd = false;
      });
    })
    # wine weixin waste too much memory, more than 4GB!!!
    #(import ./weixin.nix {})
    wemeet
    (nur.repos.xddxdd.dingtalk.overrideAttrs (old: {
      installPhase = builtins.replaceStrings [
        "libcef.so"
        "--prefix LD_PRELOAD"
      ][
        "plugins/dtwebview/libcef.so"
        # Fix: cannot enable executable stack as shared object requires: Invalid argument
        # https://unix.stackexchange.com/questions/792460/dlopen-fails-after-debian-trixie-libc-transition-cannot-enable-executable-st
        "--prefix GLIBC_TUNABLES : glibc.rtld.execstack=2 --prefix LD_PRELOAD"
      ] old.installPhase;
    }))
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
