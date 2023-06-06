{ config, pkgs, stdenv, lib, ... }:
{
  imports = [{
    home.packages = [pkgs.clash];
    systemd.user.services.clash = {
      Unit = {
        Description = "Auto start clash";
        After = ["network.target"];
      };
      Install = {
        WantedBy = ["default.target"];
      };
      Service = {
        ExecStart = "${pkgs.clash.outPath}/bin/clash -d ${config.home.homeDirectory}/Gist/clash";
      };
    };
    programs.bash.bashrcExtra = lib.optionalString (!config.isNixOnDroid) ''
      # proxy
      ## default
      HTTP_PROXY="http://127.0.0.1:${toString config.proxyPort}/"
      ## microsoft wsl
      if [[ $(uname -r) == *"microsoft"* ]]; then
          hostip=$(cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }')
          export HTTP_PROXY="http://$hostip:${toString config.proxyPort}"
      fi
      export HTTPS_PROXY="$HTTP_PROXY"
      export HTTP_PROXY="$HTTP_PROXY"
      export FTP_PROXY="$HTTP_PROXY"
      export http_proxy="$HTTP_PROXY"
      export https_proxy="$HTTP_PROXY"
      export ftp_proxy="$HTTP_PROXY"
    '';
  }];
}
