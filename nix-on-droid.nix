{ pkgs, config, ... }:
let
  sshdTmpDirectory = "${config.user.home}/sshd-tmp";
  sshdDirectory = "${config.user.home}/sshd";
  pathToPubKey = "${config.user.home}/.ssh/id_rsa.pub";
  port = 8022;
in
{
  # Simply install just the packages
  environment.packages = with pkgs; [
    # User-facing stuff that you really really want to have
    vim  # or some other editor, e.g. nano or neovim

    # sshd-start script
    # refers to: https://github.com/t184256/nix-on-droid/wiki/SSH-access
    (pkgs.writeScriptBin "sshd-start" ''
      #!${pkgs.runtimeShell}

      echo "Starting sshd in non-daemonized way on port ${toString port}"
      ${pkgs.openssh}/bin/sshd -f "${sshdDirectory}/sshd_config" -D
    '')

    # Some common stuff that people expect to have
    diffutils
    findutils
    utillinux
    tzdata
    hostname
    man
    gnugrep
    gnupg
    gnused
    gnutar
    bzip2
    gzip
    xz
    zip
    unzip
  ];

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "21.11";

  # After installing home-manager channel like
  #   nix-channel --add https://github.com/rycee/home-manager/archive/release-21.11.tar.gz home-manager
  #   nix-channel --update
  # you can configure home-manager in here like
  home-manager.config = import ./usr/cli.nix;
  #home-manager.config =
  #  { pkgs, lib, ... }:
  #  {
  #    # Read the changelog before changing this value
  #    home.stateVersion = "21.11";
  #
  #    # Use the same overlays as the system packages
  #    nixpkgs = { inherit (config.nixpkgs) overlays; };
  #
  #    # insert home-manager config
  #  };
  # If you want the same pkgs instance to be used for nix-on-droid and home-manager
  #home-manager.useGlobalPkgs = true;
  build.activation.sshd = ''
    $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${config.user.home}/.ssh"
    $DRY_RUN_CMD cat ${pathToPubKey} > "${config.user.home}/.ssh/authorized_keys"

    if [[ ! -d "${sshdDirectory}" ]]; then
      $DRY_RUN_CMD rm $VERBOSE_ARG --recursive --force "${sshdTmpDirectory}"
      $DRY_RUN_CMD mkdir $VERBOSE_ARG --parents "${sshdTmpDirectory}"

      $VERBOSE_ECHO "Generating host keys..."
      $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keygen -t rsa -b 4096 -f "${sshdTmpDirectory}/ssh_host_rsa_key" -N ""

      $VERBOSE_ECHO "Writing sshd_config..."
      $DRY_RUN_CMD echo -e "HostKey ${sshdDirectory}/ssh_host_rsa_key\nPort ${toString port}\n" > "${sshdTmpDirectory}/sshd_config"

      $DRY_RUN_CMD mv $VERBOSE_ARG "${sshdTmpDirectory}" "${sshdDirectory}"
    fi
  '';
  build.activation.termux = ''
    mkdir -p ${config.user.home}/.termux
    if [[ -f ${config.user.home}/Gist/Config/termux.properties ]]
    then
      ln -s ${config.user.home}/Gist/Config/termux.properties ${config.user.home}/.termux/
    fi
  '';
}

# vim: ft=nix
