#MC # usr/default.nix
#MC
#MC home-manager的入口配置文件，它导入了：
#MC
#MC * [`./usr/cli`](./usr/cli/default.nix.md)：我的所有CLI程序的配置
#MC * [`./usr/gui`](./usr/gui/default.nix.md)：我的所有GUI程序的配置
#MC
#MC 因为部分系统不需要GUI程序，比如安卓手机nix-on-droid或是树莓派等。
#MC 我利用环境变量`DISPLAY`用于判断是否导入GUI程序的配置。

{ config, ... }: {
  imports = [
    ./modules
    ./cli
    ./gui
  ];
  home.stateVersion = "25.05";

  news.display = "silent";

  programs.zsh.initContent = ''
    . ${toString ../scripts/bootstrap/main.sh}
  '';
  # envExtra gives non-interactive zsh, such as ssh 'cmd', the existing pin paths.
  # initContent runs the heavier bootstrap repair only for interactive shells.
  programs.zsh.envExtra = /*bash*/ ''
    if [[ -e "$HOME/.config/npins/nixpkgs" && -e "$HOME/.config/npins/home-manager" ]]; then
      export NIX_PATH="nixpkgs=$HOME/.config/npins/nixpkgs:home-manager=$HOME/.config/npins/home-manager${
        if config.isNixOnDroid
        then ":nix-on-droid=$HOME/.config/npins/nix-on-droid"
        else ":nixos-config=/etc/nixos/configuration.nix"
      }"
    fi
  '';
}
