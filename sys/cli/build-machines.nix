{ pkgs, ... }: {
  system.activationScripts.ssh_config = let
    # nix-daemon's ssh cannot find nc,
    # so I replace nc with absolute path.
    # The absolute path is recommended way in ssh ProxyCommand,
    # see `man ssh_config`
    ssh_config = pkgs.runCommand "ssh_config" {} ''
      sed 's,\<nc\>,${pkgs.libressl.nc}/bin/nc,g' ${/home/xieby1/Gist/Config/ssh.conf} > $out
    '';
  in ''
    ln -sfn ${ssh_config} /root/.ssh/config
    if [[ ! -e /root/.ssh/id_rsa ]]; then
      cp /home/xieby1/Gist/Vault/id_rsa* /root/.ssh/
      chmod 600 /root/.ssh/id_rsa
    fi
  '';
}
