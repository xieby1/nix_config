# xieby1的nixos home-manager配置

基本思路：

* 系统配置`configuration.nix`和用户配置`home.nix`分开
* 图形`gui.nix`和命令行`cli.nix`分开
* 尽可能复用已有的配置
  * [TODO]vim
* 先在虚拟机qemu中踩坑，之后再迁移到物理机
* 先用好nix expression，之后再学习flake

## [TODO]QEMU中安装NixOS

