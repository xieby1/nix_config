# xieby1的nixos home-manager配置

目前的配置出来的操作系统，已经达到基本可用水平<img src="https://www.emojiall.com/img/platform/wechat/wx035.png" style="height: 1em;" />。

从ubunt20迁移到nixos，软件的选择和配置习惯会倾向于ubuntu20。

配置基本思路：

* 系统配置`system.nix`和用户配置`home.nix`分开
* 图形`gui`和命令行`cli`分开
* 先在虚拟机qemu中踩坑，之后再迁移到物理机
* 先用好nix expression，之后再学习flake

部分软件配置：

* x11 gnome桌面
  * gnome extensions、gnome的快捷键等，通过dconf配置
* qv2ray科学上网
* vim支持的不好，用neovim代替
  * nixpkgs未支持的vim插件，通过buildVimPlugin添加
* 输入法使用fcitx

## QEMU中安装NixOS

```bash
qemu-system-x86_64 -display gtk,window-close=off -vga virtio -device e1000,netdev=net0 -netdev user,id=net0,hostfwd=tcp::5556-:22,smb=/home/xieby1/ -m 4G -smp 3 -enable-kvm -hda ~/Img/nix.qcow2 &
```

参考官方的步骤[NixOS - NixOS 21.11 manual](https://nixos.org/manual/nixos/stable/#sec-installation)安装，使用MBR，如下

```bash
# mkfs.ext4 -L nixos /dev/sda1
# mkswap -L swap /dev/sda2
# swapon /dev/sda2
# mount /dev/disk/by-label/nixos /mnt
# nixos-generate-config --root /mnt

# 在imports中添加system.nix的路径
# nano /mnt/etc/nixos/configuration.nix

# 替换为清华的unstable
# nix-channel --add https://mirror.tuna.tsinghua.edu.cn/nix-channels/nixos-unstable nixos

# nixos-install
# reboot
```

将仓库放到在`~/.config/nixpkgs`，

```bash
sudo nix-channel --add https://mirror.tuna.tsinghua.edu.cn/nix-channels/nixos-unstable nixosnix-channel nixos
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
sudo nixos-rebuild switch
home-manager switch
```









