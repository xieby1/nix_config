{ config, pkgs, stdenv, lib, ... }: {
  imports = [{
    home.packages = [
      pkgs.clash-meta
    ];
    systemd.user.services.clash = {
      Unit = {
        Description = "Auto start clash";
        After = ["network.target"];
      };
      Install = {
        WantedBy = ["default.target"];
      };
      Service = {
        ExecStart = "${pkgs.clash-meta.outPath}/bin/clash-meta -d ${config.home.homeDirectory}/Gist/clash";
      };
    };
    programs.zsh.initContent = lib.mkBefore (lib.optionalString (!config.isNixOnDroid) ''
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
  }];
}
