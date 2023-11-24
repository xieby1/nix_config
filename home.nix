#MC # home.nix
#MC
#MC `home.nix`是home-manager的入口配置文件，它导入了3个nix文件：
#MC
#MC * `./opt.nix`：我定义的全局变量
#MC * `./usr/cli.nix`：我的所有CLI程序的配置
#MC * `./usr/gui.nix`：我的所有GUI程序的配置
#MC
#MC 因为部分系统不需要GUI程序，比如安卓手机nix-on-droid或是树莓派等。
#MC 我利用环境变量`DISPLAY`用于判断是否导入GUI程序的配置。

{ config, pkgs, stdenv, lib, ... }:

{
  imports = [
    ./opt.nix
    ./usr/cli.nix
    # Q: how to use isGui here?
    # A: Not possible.
    #    As isGui is evaluated after `imports` being evaluated,
    #    use config.isGui here cause infinite loop.
  ] ++ lib.optionals ((builtins.getEnv "DISPLAY")!="") [
    ./usr/gui.nix
  ];

  home.stateVersion = "18.09";
  programs.home-manager.enable = true;
}
