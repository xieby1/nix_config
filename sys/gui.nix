{ config, pkgs, ... }:

{
  imports = [ # files

  ] ++ [{ # functions & attrs
    # support fractional scaling for x11 gnome:
    # refer to https://nixos.wiki/wiki/Overlays#Overriding_a_package_inside_a_scope
    nixpkgs.overlays = [ (final: prev: {
      gnome = prev.gnome.overrideScope' (gfinal: gprev: {
        mutter = let
          mutter-x11-scaling = pkgs.fetchFromGitHub {
            owner = "puxplaying";
            repo = "mutter-x11-scaling";
            rev = "dca2dca4b6fd769abb158c1728e7a9277dd2d478";
            hash = "sha256-xK8kDmGwB/a85qS2EsEOviaNGcAsV6vNlE1UQElzcnE=";
          };
        in gprev.mutter.overrideAttrs (old: {
          patches = (pkgs.lib.optionals (old ? patches) old.patches) ++ [
            "${mutter-x11-scaling}/mutter-45.0-x11-Add-support-for-fractional-scaling-using-Randr.patch"
          ];
        });
        gnome-control-center = let
          gnome-control-center-x11-scaling = pkgs.fetchFromGitHub {
            owner = "puxplaying";
            repo = "gnome-control-center-x11-scaling";
            rev = "758a28e2c0e6f3cbe5c59154a850504d7c56e81b";
            hash = "sha256-vRiZXqpWyU4c0hvJXVCoqfbYPtePGOI6hZO/bJ4/6D8=";
          };
        in gprev.gnome-control-center.overrideAttrs (old: {
          patches = (pkgs.lib.optionals (old ? patches) old.patches) ++ [
            "${gnome-control-center-x11-scaling}/gnome-control-center-45.0-display-Support-UI-scaled-logical-monitor-mode.patch"
            "${gnome-control-center-x11-scaling}/gnome-control-center-45.0-display-Allow-fractional-scaling-to-be-enabled.patch"
          ];
        });
      });
    }) ];

    # push the overrided mutter and gnome to my cachix
    cachixPackages = with pkgs.gnome; [mutter gnome-control-center];
  }] ;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [
    "nvidia"
    # default video drivers
    "radeon" "nouveau" "modesetting" "fbdev"
    "intel" "amdgpu"
  ];

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.gnome.enable = true;

  # https://discourse.nixos.org/t/how-to-create-folder-in-var-lib-with-nix/15647
  system.activationScripts.user_account_conf = pkgs.lib.stringAfter [ "var" ] (let
    face = pkgs.fetchurl {
      url = "https://github.com/xieby1.png";
      sha256 = "1s20qy3205ljp29lk0wqs6aw5z67db3c0lvnp0p7v1q2bz97s9bm";
    };
  in ''
    mkdir -p /var/lib/AccountsService/users
    if [[ ! -f /var/lib/AccountsService/users/xieby1 ]]; then
    cat > /var/lib/AccountsService/users/xieby1 <<XIEBY1_ACCOUNT
    [User]
    Session=
    Icon=/var/lib/AccountsService/icons/xieby1
    SystemAccount=false
    XIEBY1_ACCOUNT
    fi
    mkdir -p /var/lib/AccountsService/icons
    ln -sf ${face} /var/lib/AccountsService/icons/xieby1
  '');

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
  i18n.inputMethod.enabled = "ibus";
  i18n.inputMethod.ibus.engines = with pkgs.ibus-engines; [
    rime
    # keyboard layout is wrong in anthy, e.g. punctuations
    # anthy
    # hinagara toggle setting is absent in mozc
    mozc
    hangul
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
    # (stdenv.mkDerivation {
    #   name = "my_fonts";
    #   srcs = [(fetchurl {
    #     url = "https://github.com/lxgw/LxgwWenKai/releases/download/v1.311/LXGWWenKai-Bold.ttf";
    #     sha256 = "16111vvjii2hmnigjb44rjj39k8hjawbvwrb3f2f1ph4hv5wnvkn";
    #   }) (fetchurl {
    #     url = "https://github.com/lxgw/LxgwWenKai/releases/download/v1.311/LXGWWenKai-Regular.ttf";
    #     sha256 = "103mvbpg51jvda265f29sjq17jj76dgwz6f1qdmv6d99bb8b6x7w";
    #   })];
    #   sourceRoot = "./";
    #   unpackCmd = ''
    #     ttfName=$(basename $(stripHash $curSrc))
    #     cp $curSrc ./$ttfName
    #   '';
    #   installPhase = ''
    #     mkdir -p $out/share/fonts/truetype
    #     cp -a *.ttf $out/share/fonts/truetype/
    #   '';
    # })
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

  hardware.xone.enable = true;

  programs.evolution = {
    enable = true;
    plugins = [pkgs.evolution-ews];
  };

}
