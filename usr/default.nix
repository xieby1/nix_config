#MC # usr/default.nix
#MC
#MC home-manager的入口配置文件，它导入了：
#MC
#MC * [`./usr/cli`](./usr/cli/default.nix.md)：我的所有CLI程序的配置
#MC * [`./usr/gui`](./usr/gui/default.nix.md)：我的所有GUI程序的配置
#MC
#MC 因为部分系统不需要GUI程序，比如安卓手机nix-on-droid或是树莓派等。
#MC 我利用环境变量`DISPLAY`用于判断是否导入GUI程序的配置。

{ ... }: {
  imports = [
    ../modules
    ./modules/cachix.nix
    ./cli
    ./gui
  ];
  news.display = "silent";
}
