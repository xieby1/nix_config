{ config, pkgs, stdenv, lib, ... }:
let
  isNixOnDroid = config.home.username == "nix-on-droid";
  proxyPort = "8889";
  tailscale-wrapper = {suffix, port}: let
    tailscale-wrapped = pkgs.writeShellScriptBin "tailscale-${suffix}" ''
      tailscale --socket /tmp/tailscale-${suffix}.sock $@
    '';
    stateDir = "${config.home.homeDirectory}/.local/share/tailscale-${suffix}";
    tailscaled-wrapped = pkgs.writeShellScriptBin "tailscaled-${suffix}" ''
      TS_LOGS_DIR="${stateDir}" \
        ${pkgs.tailscale}/bin/tailscaled \
        --tun userspace-networking \
        --outbound-http-proxy-listen=localhost:${port} \
        --socket=/tmp/tailscale-${suffix}.sock \
        --state=${stateDir}/tailscaled.state \
        --statedir=${stateDir} \
        $@
    '';
  in {
    home.packages = [tailscale-wrapped tailscaled-wrapped];
    systemd.user.services."tailscaled-${suffix}" = {
      Unit = {
        Description = "Auto start tailscaled-${suffix} userspace network";
        After = ["clash.service"];
      };
      Install = {
        WantedBy = ["default.target"];
      };
      Service = {
        Environment = [
          "HTTPS_PROXY=http://127.0.0.1:${proxyPort}"
          "HTTP_PROXY=http://127.0.0.1:${proxyPort}"
          "https_proxy=http://127.0.0.1:${proxyPort}"
          "http_proxy=http://127.0.0.1:${proxyPort}"
        ];
        ExecStart = "${tailscaled-wrapped}/bin/tailscaled-${suffix}";
      };
    };
  };
  tailscale-bash-completion = builtins.derivation {
    name = "tailscale-bash-completion";
    system = builtins.currentSystem;
    src = builtins.fetchurl "https://gist.githubusercontent.com/cmtsij/f0d0be209224a7bdd67592695e1427de/raw/tailscale";
    builder = pkgs.writeShellScript "tailscale-bash-completion-builder" ''
      source ${pkgs.stdenv}/setup
      dstdir=$out/share/bash-completion/completions
      dst=$dstdir/tailscale
      mkdir -p $dstdir
      cp $src $dst
      chmod +w $dst
      echo "complete -F _tailscale tailscale-headscale" >> $dst
      echo "complete -F _tailscale tailscale-official" >> $dst
      chmod -w $dst
      cd $dstdir
      ln -s tailscale tailscale-headscale
      ln -s tailscale tailscale-official
    '';
  };
in {
  imports = [{
    home.packages = [pkgs.tailscale tailscale-bash-completion];
    programs.bash.bashrcExtra = lib.optionalString isNixOnDroid ''
      # start tailscale
      if [[ -z "$(ps|grep tailscaled|grep -v grep)" ]]; then
          tailscaled-headscale &> /dev/null &
          tailscaled-official &> /dev/null &
      fi
    '';
  }(tailscale-wrapper {suffix="headscale"; port="1055";}
  )(tailscale-wrapper {suffix="official";  port="1056";}
  ){
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
    programs.bash.bashrcExtra = lib.optionalString (!isNixOnDroid) ''
      # proxy
      ## default
      HTTP_PROXY="http://127.0.0.1:${proxyPort}/"
      ## microsoft wsl
      if [[ $(uname -r) == *"microsoft"* ]]; then
          hostip=$(cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }')
          export HTTP_PROXY="http://$hostip:${proxyPort}"
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
