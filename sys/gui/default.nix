{ config, pkgs, ... }:

{
  imports = [ # files

  ] ++ [{ # functions & attrs
    # support fractional scaling for x11 gnome:
    # refer to https://nixos.wiki/wiki/Overlays#Overriding_a_package_inside_a_scope
    nixpkgs.overlays = [ (final: prev: {
      mutter = let
        mutter-x11-scaling = pkgs.fetchFromGitHub {
          owner = "puxplaying";
          repo = "mutter-x11-scaling";
          rev = "d19eeb27f6efb1f489ef49e0c987a9e02a072b31";
          hash = "sha256-NOMd7wyQNj+tp2WZ9l2tKITYUvL7toZ8OvVQssR14Ng=";
        };
      in prev.mutter.overrideAttrs (old: {
        patches = (pkgs.lib.optionals (old ? patches) old.patches) ++ [
          "${mutter-x11-scaling}/x11-Add-support-for-fractional-scaling-using-Randr.patch"
        ];
      });
      gnome-control-center = let
        gnome-control-center-x11-scaling = pkgs.fetchFromGitHub {
          owner = "puxplaying";
          repo = "gnome-control-center-x11-scaling";
          rev = "ec599022bbd39455043eeb5dd03ea6f1d33bbe23";
          hash = "sha256-Y5D1p+koFBfgkbgreIV8FE+TqJrA8TJIrRQ8cQkzdB8=";
        };
      in prev.gnome-control-center.overrideAttrs (old: {
        patches = (pkgs.lib.optionals (old ? patches) old.patches) ++ [
          "${gnome-control-center-x11-scaling}/display-Support-UI-scaled-logical-monitor-mode.patch"
          "${gnome-control-center-x11-scaling}/display-Allow-fractional-scaling-to-be-enabled.patch"
        ];
      });
    }) ];

    # push the overrided mutter and gnome to my cachix
    cachix_packages = with pkgs; [mutter gnome-control-center];
  }] ;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [
    # "nvidia"
    # default video drivers
    "radeon" "nouveau" "modesetting" "fbdev"
    "modesetting" "amdgpu"
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
  services.avahi.nssmdns4 = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # https://github.com/kovidgoyal/kitty/issues/403
  environment.variables.GLFW_IM_MODULE = "ibus";
  i18n.inputMethod.enable = true;
  i18n.inputMethod.type = "ibus";
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
  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-emoji
    noto-fonts-color-emoji
    noto-fonts-extra
    # The best developer fonts, see https://www.nerdfonts.com/
    nerd-fonts.hack
    nerd-fonts.meslo-lg
    nerd-fonts.sauce-code-pro
    nerd-fonts.fira-code
    nerd-fonts.terminess-ttf
    nerd-fonts.iosevka
    nerd-fonts.monoid
    nerd-fonts.fantasque-sans-mono
  ];
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

  # for x11 gesture
  services.touchegg.enable = true;
}
