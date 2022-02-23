<!-- vim-markdown-toc GFM -->

* [xieby1的nixos配置](#xieby1的nixos配置)
    * [目录结构](#目录结构)
    * [安装](#安装)
        * [安装NixOS](#安装nixos)
            * [准备镜像](#准备镜像)
            * [分区](#分区)
            * [文件系统](#文件系统)
            * [基础配置](#基础配置)
    * [部署我的配置](#部署我的配置)
    * [部分软件配置思路](#部分软件配置思路)
        * [x11 gnome桌面](#x11-gnome桌面)
        * [qv2ray科学上网](#qv2ray科学上网)
        * [neovim代替vim](#neovim代替vim)
        * [输入法使用fcitx](#输入法使用fcitx)
        * [使用docker提供ubuntu命令行环境](#使用docker提供ubuntu命令行环境)

<!-- vim-markdown-toc -->

# xieby1的nixos配置

* 基于ubuntu的使用习惯
* QEMU✅，NixOS单系统✅，NixOS+Windows双系统✅

## 目录结构

* system.nix: 系统总体配置（nixos-rebuild的配置）
  * sys/cli.nix: 系统命令行配置
  * sys/gui.nix: 系统图形配置
* home.nix: 用户总体配置（home-manager的配置）
  * usr/cli.nix: 用户命令行配置
  * usr/gui.nix: 用户图形配置

## 安装

安装分两步，
第一步安装NixOS，
第二步部署我的配置。

### 安装NixOS

安装过程采用[官方安装文档](https://nixos.org/manual/nixos/stable/#sec-installation)。

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

## 部署我的配置

重启之后，进入NixOS。

```bash
git clone https://github.com/xieby1/nix_config.git ~/.config/nixpkgs

vim /etc/nixos/configuration.nix
# 在imports中添加system.nix的路径

# 替换为清华的最新稳定源
sudo nix-channel --add https://mirror.tuna.tsinghua.edu.cn/nix-channels/nixos-21.11 nixos
# 添加home manager源
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-21.11.tar.gz home-manager
sudo nix-channel --update
sudo nixos-rebuild switch
# 安装home-manager
nix-shell '<home-manager>' -A install
home-manager switch
```

## 部分软件配置思路

### x11 gnome桌面

autokey依赖于x11，在wayland中无法运行，因此选用x11。

gnome extensions、gnome的快捷键等，通过dconf配置

### qv2ray科学上网

### neovim代替vim

nixpkgs未支持的vim插件，通过buildVimPlugin添加

### 输入法使用fcitx

### 使用docker提供ubuntu命令行环境

