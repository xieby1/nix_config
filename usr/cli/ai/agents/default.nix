{ config, pkgs, ... }: {
  imports = [
    ./pi
    ./hermes
    ./goose
    ./zerostack
  ];
  home.file.".agents/skills".source = config.lib.file.mkOutOfStoreSymlink ~/Gist/Data/agents/skills;
}
