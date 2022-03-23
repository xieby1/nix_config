# xieby1的nixos配置

[English](./README-en.md)

* 使用nix expression，而非nix flakes
* 使用NixOS稳定源（目前版本21.11），而非非稳定源（unstable）
* 基于ubuntu的使用习惯
* 多平台：QEMU✅，NixOS单系统✅，NixOS+Windows双系统✅，安卓（nix-on-droid）✅

你可以使用该仓库的配置，配置出完整NixOS操作系统。
也可以使用其中的部分包、模块，扩充自己的Nix/NixOS。

## 目录

<!-- vim-markdown-toc GFM -->

* [文件夹结构](#文件夹结构)
* [安装](#安装)
    * [安装NixOS](#安装nixos)
        * [准备镜像](#准备镜像)
        * [分区](#分区)
        * [文件系统](#文件系统)
        * [基础配置](#基础配置)
    * [安装我的配置](#安装我的配置)
        * [导入配置](#导入配置)
        * [设置软件源](#设置软件源)
        * [部署配置](#部署配置)
* [软件配置思路](#软件配置思路)
    * [gnome桌面](#gnome桌面)
        * [Wayland or X11](#wayland-or-x11)
        * [新增模块mime.nix](#新增模块mimenix)
        * [新增模块gsettings.nix](#新增模块gsettingsnix)
    * [qv2ray科学上网](#qv2ray科学上网)
    * [文本编辑器](#文本编辑器)
        * [NeoVim or Vim](#neovim-or-vim)
        * [Typora替代品（Obsidian or Marktext）](#typora替代品obsidian-or-marktext)
    * [输入法](#输入法)
    * [chroot or docker](#chroot-or-docker)

<!-- vim-markdown-toc -->

## 文件夹结构

* system.nix: 系统总体配置（nixos-rebuild的配置）
  * sys/cli.nix: 系统命令行配置
  * sys/gui.nix: 系统图形配置
* home.nix: 用户总体配置（home-manager的配置）
  * usr/cli.nix: 用户命令行配置
  * usr/gui.nix: 用户图形配置

## 安装

安装分两步，
第一步安装NixOS，
第二步安装我的配置。

### 安装NixOS

安装过程采用[官方安装文档](https://nixos.org/manual/nixos/stable/#sec-installation)。
若已安装NixOS，则可跳过该步骤，直接看安装我的配置。

#### 准备镜像

QEMU:

```bash
# 下载minimal ISO镜像：https://nixos.org/download.html
# 创建qemu硬盘（大小32GB）
qemu-img create -f qcow2 <output/path/to/nix.qcow2> 32G
# 将ISO安装到qemu硬盘
qemu-system-x86_64 -display gtk,window-close=off -vga virtio -device e1000,netdev=net0 -netdev user,id=net0,hostfwd=tcp::5556-:22,smb=/home/xieby1/ -m 4G -smp 3 -enable-kvm -hda </path/to/nix.qcow2> -cdrom </path/to/nixos-minial.iso> -boot d &
```

物理机:

```bash
# 暂时未探究命令行连接wifi的方法
# 所以目前使用gnome版ISO，而非minimal ISO。
# 下载gnome ISO镜像：https://nixos.org/download.html
# 启动U盘制作
sudo dd if=<path/to/nixos.iso> of=</dev/your_usb>
sync
# 重启进入U盘系统
# 注：需要在BIOS中取消secure boot，否则U盘无法启动。
```

#### 分区

进入ISO系统后，创建分区。
一共需要3个分区：启动分区，操作系统分区，swap分区。
QEMU和物理机单系统需要创建这3个分区。
物理机双系统中启动分区已有，只需创建剩下2个分区。

QEMU:

```bash
sudo bash
parted /dev/sda -- mklabel msdos
parted /dev/sda -- mkpart primary 1MiB -8GiB
parted /dev/sda -- mkpart primary linux-swap -8GiB 100%
```

物理机单系统:

```bash
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart primary 512MiB -8GiB
parted /dev/sda -- mkpart primary linux-swap -8GiB 100%
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/sda -- set 3 esp on
```

物理机双系统:

还未探索parted详细用法，目前使用disk软件可视化分区。

* 创建Ext4分区，取名为nixos
* 创建Other->swap分区

#### 文件系统

```bash
mkfs.ext4 -L nixos /dev/<系统分区>
mkswap -L swap /dev/<swap分区>
swapon /dev/<swap分区>
mkfs.fat -F 32 -n boot /dev/<启动分区>      # 物理机单系统
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot                          # 物理机单系统&双系统
mount /dev/disk/by-label/boot /mnt/boot     # 物理机单系统&双系统
```

#### 基础配置

* 生成配置文件
```bash
nixos-generate-config --root /mnt
```
* 修改/mnt/etc/nixos/configuration.nix，
  * 修改名字`networking.hostName`
  * 启用代理
    * QEMU中宿主机器的ip为10.0.2.2
    * 安装过程中需要借助别的计算机或宿主机的的代理服务
    * 部署完我的nixos配置后，将会有qv2ray服务，可以用虚拟机的代理服务
    * `networking.proxy.default = "http://user:password@proxy:port/";`
    * `networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";`
  * （QEMU和物理机单系统）取消以下注释以开启grub支持
    * `boot.loader.grub.device = "/dev/sda";`
  * 取消防火墙，以便kdeconnect正常运行
    * `networking.firewall.enable = false;`
  * （物理机双系统）自动探测操作系统启动项
    * `boot.loader.grub.useOSProber = true;`
  * 添加用户
    * `users.users.xieby1`
  * 添加软件
    * `environment.systemPackages = with pkgs; [vim git];`

最后

```bash
nixos-install
reboot
```

### 安装我的配置

重启之后，进入NixOS。

#### 导入配置

在基础配置中，导入我的配置。

```bash
git clone https://github.com/xieby1/nix_config.git ~/.config/nixpkgs
vim /etc/nixos/configuration.nix
# 在imports中添加system.nix的路径
```

#### 设置软件源

```bash
# 替换为清华的最新稳定源
sudo nix-channel --add https://mirror.tuna.tsinghua.edu.cn/nix-channels/nixos-21.11 nixos
# 添加home manager源
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-21.11.tar.gz home-manager
sudo nix-channel --update
```

#### 部署配置

```bash
sudo nixos-rebuild switch
# 安装home-manager
nix-shell '<home-manager>' -A install
home-manager switch
```

## 软件配置思路

### gnome桌面

#### Wayland or X11

我使用的部分软件依赖于x11，在wayland中无法运行，因此选用x11。
例如autokey（尝试espanso代替autokey）。
在找到合适的替代品前，仍然保持x11。

界面、插件、快捷键等影响桌面系统使用体验的直观感受。
使用gui/gnome.nix中的配置gnome桌面系统。
其中的大量设置可以通过dconf查看/修改，以辅助修改。

#### 新增模块mime.nix

该模块用于配置文件类型和默认打开程序。
通过xdg-mime实现类型设置和默认程序设置。

#### 新增模块gsettings.nix

该模块用于gsettings配置。
现有的dconf.settings并不能完成所有gsettings的功能。
比如gnome-termimal的顶部栏需要通过gsettings隐藏。
原因参考[该回答](https://askubuntu.com/questions/416556/shouldnt-dconf-editor-and-gsettings-access-the-same-database)
gsettings(schema id)和dconf(schema path)存在区别。

### qv2ray科学上网

qv2ray已经停止更新，对高分辨率屏幕的适配不好。
可能的GUI替代品v2rayA。

qv2ray需要v2ray core。
通过usr/gui.nix: home.file.v2ray_core，
将v2ray core放在qv2ray默认的地址.config/qv2ray/，
由此让qv2ray开箱即用。

### 文本编辑器

#### NeoVim or Vim

NixOS社区对NeoVim和Vim的支持是不平等的，
从插件管理就能看出。

配置vim插件需要vim_configurable.customize，
十分繁杂，
详细可见nixpkgs git commit: 3feff06b4dee3fd59312204eee0a2af948098376。

NeoVim使用programs.neovim.plugins即可，
因此选用NeoVim。

#### Typora替代品（Obsidian or Marktext）

[Typora加入"anti-user encryption"](https://github.com/NixOS/nixpkgs/issues/138329)后，
nixpkgs社区停止对typora的支持。

Marktext更新慢，至今仍未支持插件。
每次关闭文件，不管是否编辑，
都会提示是否保存。

Obsidian体验还不错！

### 输入法

沿用ubuntu的使用习惯，采用fcitx。
* 中文：cloudpinyin（支持模糊音、自动联网词库）
* 日文：mozc
* 韩文：hangul

### chroot or docker

chroot需要挂载诸多目录，才能使ubuntu正常运行。
但是NixOS并不提供FHS需要的众多目录。

因此使用docker提供ubuntu命令行环境。

