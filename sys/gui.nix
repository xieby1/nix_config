{ config, pkgs, ... }:

{
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = if "${config.networking.hostName}" == "jumper"
  then ["intel"]
  else [];

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

  #i18n.inputMethod.enabled = "fcitx5";
  #i18n.inputMethod.fcitx5.addons = with pkgs; [
  #  fcitx5-configtool
  #  fcitx5-chinese-addons
  #  fcitx5-mozc
  #];
  i18n.inputMethod.enabled = "fcitx";
  i18n.inputMethod.fcitx.engines = with pkgs.fcitx-engines; [
    cloudpinyin
    mozc
    hangul
  ];

  nixpkgs.config.allowUnfree = true;

  # vim vista need nerd fonts
  # https://github.com/liuchengxu/vista.vim/issues/74
  # https://github.com/liuchengxu/space-vim/wiki/tips#programming-fonts
  # available nerd fonts: nixpkgs/pkgs/data/fonts/nerdfonts/shas.nix
  fonts.fonts = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
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
  ];
  # enable fontDir /run/current-system/sw/share/X11/fonts
  fonts.fontDir.enable = true;

  services.gpm.enable = true;
}
