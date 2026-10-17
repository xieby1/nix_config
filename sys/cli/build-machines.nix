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
    for user_id_pub in /home/xieby1/Gist/Vault/id_*.pub; do
        user_id=''${user_id_pub%.pub}
        root_id_pub=/root/.ssh/''${user_id_pub##*/}
        root_id=''${root_id_pub%.pub}
      if [[ ! -e $root_id_pub ]]; then
        cp $user_id_pub $root_id_pub
        cp $user_id     $root_id
        chmod 600 $root_id
      fi
    done
  '';
}
