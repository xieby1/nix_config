{ config, pkgs, lib, isNixOnDroid, ... }: {
  imports = [
    ./tui
  ];
  options.proxyPort = lib.mkOption {
    type = lib.types.number;
    default = 8889;
    description = "代理端口号，诸多网络程序需要用，比如clash和tailscale";
  };

  config = {
    home.packages = [
      pkgs.mihomo
    ];
    # mihomo rewrites this bbolt DB at runtime (selected proxies, fake-ip mappings, provider etags);
    # syncing a live, locked DB across devices corrupts it.
    my.syncthing.Gist-stignore = [ "/clash/cache.db" ];
    systemd.user.services.clash = {
      Unit = {
        Description = "Auto start clash";
        After = ["network.target"];
      };
      Install = {
        WantedBy = ["default.target"];
      };
      Service = {
        ExecStart = "${pkgs.mihomo}/bin/mihomo -d ${config.home.homeDirectory}/Gist/clash";
      };
    };
    programs.zsh.envExtra = lib.mkBefore (lib.optionalString (!isNixOnDroid) ''
      # proxy
      ## default
      HTTP_PROXY="http://127.0.0.1:${toString config.proxyPort}"
      ## microsoft wsl
      # if [[ $(uname -r) == *"microsoft"* ]]; then
      #     hostip=$(cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }')
      #     export HTTP_PROXY="http://$hostip:${toString config.proxyPort}"
      # fi
      export HTTPS_PROXY="$HTTP_PROXY"
      export HTTP_PROXY="$HTTP_PROXY"
      export FTP_PROXY="$HTTP_PROXY"
      export http_proxy="$HTTP_PROXY"
      export https_proxy="$HTTP_PROXY"
      export ftp_proxy="$HTTP_PROXY"
    '');
    programs.nushell.environmentVariables = let
      HTTP_PROXY = "http://127.0.0.1:${toString config.proxyPort}";
    in lib.optionalAttrs (!isNixOnDroid) {
      HTTPS_PROXY = HTTP_PROXY;
      HTTP_PROXY  = HTTP_PROXY;
      FTP_PROXY   = HTTP_PROXY;
      http_proxy  = HTTP_PROXY;
      https_proxy = HTTP_PROXY;
      ftp_proxy   = HTTP_PROXY;
    };

    programs.zsh.initContent = lib.mkBefore (lib.optionalString (!isNixOnDroid) ''
      unset_proxy() {
        unset HTTPS_PROXY
        unset HTTP_PROXY
        unset FTP_PROXY
        unset https_proxy
        unset http_proxy
        unset ftp_proxy
        unset HTTPS_PORT
        unset HTTP_PORT
        unset FTP_PORT
        unset https_port
        unset http_port
        unset ftp_port
        unset ALL_PROXY
        unset all_proxy
        unset NO_PROXY
        unset no_proxy
        unset RSYNC_PROXY
        unset rsync_proxy
      }
    '');
    programs.nushell.extraConfig = lib.optionalString (!isNixOnDroid) ''
      def --env unset_proxy [] {
        hide-env HTTPS_PROXY
        hide-env HTTP_PROXY
        hide-env FTP_PROXY
        hide-env https_proxy
        hide-env http_proxy
        hide-env ftp_proxy
        hide-env HTTPS_PORT
        hide-env HTTP_PORT
        hide-env FTP_PORT
        hide-env https_port
        hide-env http_port
        hide-env ftp_port
        hide-env ALL_PROXY
        hide-env all_proxy
        hide-env NO_PROXY
        hide-env no_proxy
        hide-env RSYNC_PROXY
        hide-env rsync_proxy
     }
    '';
  };
}
