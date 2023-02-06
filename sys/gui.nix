{ config, pkgs, ... }:

{
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [
    "intel" "amdgpu"
    # default video drivers
    "radeon" "nouveau" "modesetting" "fbdev"
  ];

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # https://nixos.wiki/wiki/Printing
  services.printing.enable = true;
  services.printing.drivers = [pkgs.hplip];
  services.avahi.enable = true;
  services.avahi.nssmdns = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # https://github.com/kovidgoyal/kitty/issues/403
  environment.variables.GLFW_IM_MODULE = "ibus";
  i18n.inputMethod.enabled = "fcitx5";
  i18n.inputMethod.fcitx5.addons = with pkgs; [
    fcitx5-configtool
    fcitx5-chinese-addons
    fcitx5-mozc
    fcitx5-hangul
  ];

  nixpkgs.config.allowUnfree = true;

  # vim vista need nerd fonts
  # https://github.com/liuchengxu/vista.vim/issues/74
  # https://github.com/liuchengxu/space-vim/wiki/tips#programming-fonts
  # available nerd fonts: nixpkgs/pkgs/data/fonts/nerdfonts/shas.nix
  ## use non-variable noto font for feishu and other old electron apps
  ## for more details see: https://github.com/NixOS/nixpkgs/issues/171976
  fonts.fonts = (
    with (import (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/d881cf9fd64218a99a64a8bdae1272c3f94daea7.tar.gz";
      sha256 = "1jaghsmsc05lvfzaq4qcy281rhq3jlx75q5x2600984kx1amwaal";
    }) {}); [
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-emoji]) ++ (with pkgs; [
    (nerdfonts.override {
      fonts = [
        "SourceCodePro"
        "Iosevka"
        "FiraCode"
        "FantasqueSansMono"
      ];
    })
    # refs to pkgs/data/fonts/roboto-mono/default.nix
    (stdenv.mkDerivation {
      name = "my_fonts";
      srcs = [(fetchurl {
        url = "https://github.com/lxgw/LxgwWenKai/releases/download/v1.235.2/LXGWWenKai-Bold.ttf";
        sha256 = "1v7bczjnadzf2s8q88rm0pf66kaymq3drsll4iy3i5axpbimap18";
      }) (fetchurl {
        url = "https://github.com/lxgw/LxgwWenKai/releases/download/v1.235.2/LXGWWenKai-Regular.ttf";
        sha256 = "06kpqgar0vvsng4gzsnj1app1vkv7v07yqgi5mfwzxch0di5qk3v";
      })];
      sourceRoot = "./";
      unpackCmd = ''
        ttfName=$(basename $(stripHash $curSrc))
        cp $curSrc ./$ttfName
      '';
      installPhase = ''
        mkdir -p $out/share/fonts/truetype
        cp -a *.ttf $out/share/fonts/truetype/
      '';
    })
  ]);
  # enable fontDir /run/current-system/sw/share/X11/fonts
  fonts.fontDir.enable = true;
  fonts.fontconfig.defaultFonts = {
    monospace = [
      "DejaVu Sans Mono"
      "Noto Color Emoji"
      "Noto Emoji"
    ];
  };

  services.gpm.enable = true;
  virtualisation.waydroid.enable = true;
}
