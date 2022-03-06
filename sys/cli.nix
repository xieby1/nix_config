{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    file
    wget
    fzf
  ];

  # neovim
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  programs.neovim.viAlias = true;
  programs.neovim.vimAlias = true;

  # ssh
  services.openssh.enable = true;
  programs.ssh.extraConfig =
    if builtins.pathExists ~/Gist/Config/ssh.conf
    then
      builtins.readFile ~/Gist/Config/ssh.conf
    else
      "";

  # syncthing
  services.syncthing = {
    enable = true;
    systemService = true;
    relay.enable = true;
    user = "xieby1";
    dataDir = "/home/xieby1";
    overrideDevices = false;
    overrideFolders = false;
  };

  # refers to https://www.golinuxcloud.com/automount-file-system-systemd-rhel-centos-7-8/
  systemd.mounts = if "${config.networking.hostName}" == "jumper"
  then [{
    enable = true;
    # [Unit]
    description = "My SD Card";
    unitConfig = {
      DefaultDependencies = "no";
      Conflicts = "umount.target";
    };
    before = ["local-fs.target" "umount.target"];
    after = ["swap.target"];
    # [Mount]
    what = "/dev/disk/by-label/home";
    where = "/home";
    type = "ext4";
    options = "defaults";
    # [Install]
    wantedBy = ["multi-user.target"];
  }] else [];

  systemd.automounts = if "${config.networking.hostName}" == "jumper"
  then [{
    enable = true;
    # [Unit]
    description = "automount sdcard";
    # [Automount]
    where = "/home";
    # [Install]
    wantedBy = ["multi-user.target"];
  }] else [];

  boot.supportedFilesystems = [ "ntfs" ];

  virtualisation.podman.enable = true;
}
