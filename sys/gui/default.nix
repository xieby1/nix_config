{ pkgs, ... }: {
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [
    # "nvidia"
    # default video drivers
    "radeon" "nouveau" "modesetting" "fbdev"
    "modesetting" "amdgpu"
  ];

  # Enable the KDE Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

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
    noto-fonts-color-emoji
    noto-fonts
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
