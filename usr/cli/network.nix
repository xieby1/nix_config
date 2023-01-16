{ config, pkgs, stdenv, lib, ... }:
let
  isNixOnDroid = config.home.username == "nix-on-droid";
  proxyPort = "8889";
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
    '';
  };
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
    tailscale-wrapped-bash-completion = builtins.derivation {
      name = "tailscale-${suffix}-bash-completion";
      system = builtins.currentSystem;
      builder = pkgs.writeShellScript "tailscale-${suffix}-bash-completion-builder" ''
        source ${pkgs.stdenv}/setup
        reldir=share/bash-completion/completions
        dstdir=$out/$reldir
        dst=$dstdir/tailscale-${suffix}
        mkdir -p $dstdir
        touch $dst
        echo ". ${tailscale-bash-completion}/$reldir/tailscale" >> $dst
        echo "complete -F _tailscale tailscale-${suffix}" >> $dst
      '';
    };
  in {
    home.packages = [
      tailscale-wrapped
      tailscaled-wrapped
      tailscale-wrapped-bash-completion
    ];
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
    programs.bash.bashrcExtra = lib.optionalString isNixOnDroid ''
      # start tailscale-${suffix}
      if [[ -z "$(ps|grep tailscaled-${suffix}|grep -v grep)" ]]; then
          tailscaled-${suffix} &> /dev/null &
      fi
    '';
  };
in {
  imports = [{
    home.packages = [pkgs.tailscale tailscale-bash-completion];
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
