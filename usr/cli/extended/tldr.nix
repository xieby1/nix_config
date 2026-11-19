{ pkgs, ... }: {
  home.packages = [
    pkgs.tlrc
  ];
  home.file.tlrc_config = {
    target = ".config/tlrc/config.toml";
    text = pkgs.lib.generators.toINI {} {
      cache = {
        dir = ''"~/.cache/tlrc"''; # this is the default dir
        auto_update = false;
      };
    };
  };
  home.file.tldr_cache = {
    target = ".cache/tlrc";
    source = builtins.fetchTarball "https://github.com/tldr-pages/tldr/archive/main.tar.gz";
  };
}
