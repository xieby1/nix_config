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

  virtualisation.docker.enable = true;
  # skopeo need this
  virtualisation.containers.enable = true;

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
}
