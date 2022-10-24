{ config, pkgs, stdenv, lib, ... }:
let
  feishu = pkgs.callPackage ./gui/feishu.nix {};
  imhex = pkgs.callPackage ./gui/imhex.nix {};
  xelfviewer = pkgs.callPackage ./gui/xelfviewer.nix {};
  mykdeconnect = pkgs.kdeconnect;
  #mykdeconnect = pkgs.kdeconnect.overrideAttrs (old: {
  #  patches = [( pkgs.fetchpatch {
  #    url = "https://raw.githubusercontent.com/xieby1/kdeconnect-kde-enhanced/4610431b932b2fab05d7e0fc55e7306dc7ff0910/diff.patch";
  #    hash = "sha256-NL/TVOMEhdJ/W7UTxjF7Qjnq7JciNvl08BC1wrBfvHo=";
  #  })];
  #  # cmakeFlags = "-DCMAKE_BUILD_TYPE=Debug -DQT_FORCE_STDERR_LOGGING=1";
  #});
  singleton = pkgs.writeShellScriptBin "singleton.sh" ''
    if [[ $# -lt 2 || $1 == "-h" ]]
    then
      echo "Usage: ''${0##*/} <window> <command and its args>"
      echo "  Only start a app once, if the app is running"
      echo "  then bring it to foreground"
      exit 0
    fi

    if [[ "$1" == "kdeconnect.app" ]]
    then
      WID=$(${pkgs.xdotool}/bin/xdotool search --classname "$1")
    else
      WID=$(${pkgs.xdotool}/bin/xdotool search --onlyvisible --name "$1")
    fi

    if [[ -z $WID ]]
    then
      eval "''${@:2}"
    else
      for WIN in $WID
      do
        CURDESK=$(${pkgs.xdotool}/bin/xdotool get_desktop)
        ${pkgs.xdotool}/bin/xdotool set_desktop_for_window $WIN $CURDESK
        ${pkgs.xdotool}/bin/xdotool windowactivate $WIN
      done
    fi
  '';
  singleton_sh = "${singleton}/bin/singleton.sh";
  webapp = pkgs.writeShellScriptBin "webapp.sh" ''
    if [[ $# -lt 2 || "$1" == "-h" ]]
    then
      echo "Usage: ''${0##*/} <window> <url>"
      echo "  Only start a webapp once, if the app is running"
      echo "  then bring it to foreground"
      exit 0
    fi

    # check URL prefix
    URL=$2
    if [[ "$URL" =~ ^~ ]]
    then
      URL="file://$HOME/''${URL#\~/}"
    fi
    if [[ "$URL" =~ ^\/ ]]
    then
      URL="file://$URL"
    fi
    if [[ "$URL" =~ ^(file|https?)?:\/\/ ]]
    then
      true
    else
      URL="https://$URL"
    fi

    # You Can Change To Chrome-Like Browser Here!
    ${singleton_sh} "$1" ${pkgs.google-chrome}/bin/google-chrome-stable --app="$URL"
  '';
  webapp_sh = "${webapp}/bin/webapp.sh";
in
{
  imports = [
    ./gui/gnome.nix
    ./gui/mime.nix
    ./gui/terminal.nix
  ];

  home.packages = with pkgs; [
    # browser
    google-chrome
    firefox
    # network
    mykdeconnect
    feishu
    (import ./gui/weixin.nix)
    # text
    #wpsoffice
    libreoffice
    obsidian
    meld
    espanso
    # draw
    drawio
    #aseprite-unfree
    inkscape
    gimp
    # viewer
    xdot
    imhex
    xelfviewer
    vlc
    # management
    zotero
    # entertainment
    mgba
    dgen-sdl # sega md emulator
    ## icon miss?
    #(retroarch.override {
    #  cores = with libretro; [
    #    libretro.beetle-gba
    #  ];
    #})
    # music
    spotify
    # runXonY
    wineWowPackages.stable
    winetricks
    # scripts
    webapp
    singleton
  ];

  xdg.desktopEntries = {
    xdot = {
      name = "xdot";
      exec = "xdot %U";
    };

    # web apps
    ## microsoft's
    todo = {
      name = "Microsoft To Do";
      genericName = "ToDo";
      exec = "${webapp_sh} \"To Do\" https://to-do.live.com/";
      icon = (pkgs.fetchurl {
        url = "https://todo.microsoft.com/favicon.ico";
        sha256 = "1742330y3fr79aw90bysgx9xcfx833n8jqx86vgbcp21iqqxn0z8";
      }).outPath;
    };
    calendar = {
      name = "Microsoft Calendar";
      exec = "${webapp_sh} Outlook https://outlook.live.com/calendar";
      icon = (pkgs.fetchurl {
        url = "https://cdn.cdnlogo.com/logos/o/82/outlook.svg";
        sha256 = "0544z9vmghp4lgapl00n99vksm0gq8dfwrp7rvfpp44njnh6b6dz";
      }).outPath;
    };
    outlook = {
      name = "Microsoft Outlook";
      exec = "${webapp_sh} Outlook https://outlook.live.com";
      icon = (pkgs.fetchurl {
        url = "https://cdn.cdnlogo.com/logos/o/82/outlook.svg";
        sha256 = "0544z9vmghp4lgapl00n99vksm0gq8dfwrp7rvfpp44njnh6b6dz";
      }).outPath;
    };
    word = {
      name = "Word";
      genericName = "office";
      exec = "${webapp_sh} Word https://www.office.com/launch/word";
      icon = (pkgs.fetchurl {
        url = "https://cdn.cdnlogo.com/logos/w/19/word.svg";
        sha256 = "1ig0d8afacfl7m1n0brx82iw8c2iif3skb8dwjly4fzxikzvfmn4";
      }).outPath;
    };
    excel = {
      name = "Excel";
      genericName = "office";
      exec = "${webapp_sh} Excel https://www.office.com/launch/excel";
      icon = (pkgs.fetchurl {
        url = "https://cdn.cdnlogo.com/logos/m/96/microsoft-excel.png";
        sha256 = "07ch9kb3s82m47mm414gvig6zg2h4yffmvjvg7bvr7sil8476cs8";
      }).outPath;
    };
    powerpoint = {
      name = "PowerPoint";
      genericName = "office ppt";
      exec = "${webapp_sh} PowerPoint https://www.office.com/launch/powerpoint";
      icon = (pkgs.fetchurl {
        url = "https://cdn.cdnlogo.com/logos/p/67/powerpoint.svg";
        sha256 = "1pnb2nna2b26kyn0i92xmgdpcrqhw1cpl3vv7vvvlsxrldndhclr";
      }).outPath;
    };
    onedrive = {
      name = "OneDrive";
      exec = "${webapp_sh} OneDrive https://onedrive.live.com";
      icon = (pkgs.fetchurl {
        url = "https://cdn.cdnlogo.com/logos/m/73/microsoft-onedrive.svg";
        sha256 = "10sjz81xjcqfkd7v11vhpvdp0s2a8la9wipc3aapgybg822vhjck";
      }).outPath;
    };
    ## others
    suishouji = {
      name = "随手记";
      genericName = "suishouji";
      exec = "${webapp_sh} 随手记 https://www.sui.com/";
      icon = (pkgs.fetchurl {
        url = "https://res.sui.com/favicon.ico";
        sha256 = "01vm275n169r0ly8ywgq0shgk8lrzg79d1aarshwybwxwffj4q0q";
      }).outPath;
    };
    webweixin = {
      name = "网页微信";
      genericName = "weixin";
      exec = ''${webapp_sh} "微信|weixin" https://wx.qq.com/'';
      icon = (pkgs.fetchurl {
        url = "https://cdn.cdnlogo.com/logos/w/79/wechat.svg";
        sha256 = "1xk1dsia6favc3p1rnmcncasjqb1ji4vkmlajgbks0i3xf60lskw";
      }).outPath;
    };
    my_cheatsheet_html = {
      name = "Cheatsheet HTML";
      genericName = "cheatsheet";
      exec = ''${webapp_sh} "markdown cheatsheet" ${config.home.homeDirectory}/Documents/Tech/my_cheatsheet.html'';
    };
    bing_dict = {
      name = "Bing Dict";
      genericName = "dictionary";
      exec = "${webapp_sh} bing https://cn.bing.com/dict/";
    };
    hjxd_jp = {
      name = "日语词典";
      genericName = "riyucidian";
      exec = "${webapp_sh} 日语词典 https://dict.hjenglish.com/jp/";
    };
    clash = {
      name = "clash";
      exec = "${webapp_sh} clash http://clash.razord.top";
    };

    # singleton apps
    my_cheatsheet_md = {
      name = "Cheatsheet MD";
      genericName = "cheatsheet";
      exec = "${singleton_sh} my_cheatsheet.mkd alacritty -e vim ${config.home.homeDirectory}/Documents/Tech/my_cheatsheet.mkd";
    };
    kdeconnect_app = {
      name = "(S) KDE Connect App";
      genericName = "kdeconnect";
      exec = "${singleton_sh} kdeconnect.app kdeconnect-app";
    };
  };

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

  programs.qutebrowser = {
    enable = true;
    # https://qutebrowser.org/doc/help/settings.html
    settings = {
      qt.highdpi = true;
      new_instance_open_target = "window";
    };
  };

  home.file.kde_connect_indicator = {
    source = "${mykdeconnect}/share/applications/org.kde.kdeconnect.nonplasma.desktop";
    target = ".config/autostart/org.kde.kdeconnect.nonplasma.desktop";
  };

  # espanso
  home.file.espanso = {
    source = ./gui/espanso.yml;
    target = ".config/espanso/default.yml";
  };

  systemd.user.services.espanso = {
    Unit = {
      Description = "Espanso daemon";
    };
    Install = {
      # services.espanso.enable uses "default.target" which not work
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.espanso}/bin/espanso daemon";
    };
  };
}
