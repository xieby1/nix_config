<!-- vim-markdown-toc GFM -->

* [xieby1的nixos home-manager配置](#xieby1的nixos-home-manager配置)
    * [配置基本思路](#配置基本思路)
    * [安装NixOS](#安装nixos)
        * [QEMU中安装NixOS（MBR）](#qemu中安装nixosmbr)
        * [物理机中安装NixOS（UEFI）](#物理机中安装nixosuefi)
            * [双系统](#双系统)
    * [部署我的nixos配置](#部署我的nixos配置)
    * [[TODO]部分软件配置思路](#todo部分软件配置思路)
        * [x11 gnome桌面](#x11-gnome桌面)
        * [qv2ray科学上网](#qv2ray科学上网)
        * [vim支持的不好，用neovim代替](#vim支持的不好用neovim代替)
        * [输入法使用fcitx](#输入法使用fcitx)
        * [autokey自动键盘脚本](#autokey自动键盘脚本)
        * [使用docker提供ubuntu命令行环境](#使用docker提供ubuntu命令行环境)

<!-- vim-markdown-toc -->

# xieby1的nixos home-manager配置

从ubunt20迁移到nixos，软件的选择和配置习惯会倾向于ubuntu20。
目前的配置出来的操作系统，已经达到基本可用水平<img src="https://www.emojiall.com/img/platform/wechat/wx035.png" style="height: 1em;" />。
接下来把基本可用变成好用<img src="https://www.emojiall.com/img/platform/wechat/wx035.png" style="height: 1em;" />！

## 配置基本思路

- [x] 系统配置`system.nix`和用户配置`home.nix`分开
- [x] 图形`gui`和命令行`cli`分开
- [x] 先在虚拟机qemu中踩坑，之后再迁移到物理机
  - [x] 迁移到NixOS单系统物理机
  - [x] 迁移到NixOS-Windows双系统物理机
- [ ] 先用好nix expression，之后再学习flake

## 安装NixOS

### QEMU中安装NixOS（MBR）

下载minimal ISO镜像：https://nixos.org/download.html

创建qemu硬盘（大小32GB）

```bash
qemu-img create -f qcow2 <output/path/to/nix.qcow2> 32G
```

将ISO安装到qemu硬盘

```bash
qemu-system-x86_64 -display gtk,window-close=off -vga virtio -device e1000,netdev=net0 -netdev user,id=net0,hostfwd=tcp::5556-:22,smb=/home/xieby1/ -m 4G -smp 3 -enable-kvm -hda </path/to/nix.qcow2> -cdrom </path/to/nixos-minial.iso> -boot d &
```

参考官方的步骤[NixOS - NixOS 21.11 manual](https://nixos.org/manual/nixos/stable/#sec-installation)安装，使用MBR，如下

```bash
# 需要sudo，或者root用户执行
mkfs.ext4 -L nixos /dev/sda1
mkswap -L swap /dev/sda2
swapon /dev/sda2
mount /dev/disk/by-label/nixos /mnt
nixos-generate-config --root /mnt
nano /mnt/etc/nixos/configuration.nix # 修改如下
  # 修改名字networking.hostName
  # 取消以下注释以开起代理
  # 将代理设置为自己的服务器，qemu中宿主机器的ip为10.0.2.2
  # 安装过程中需要借助别的计算机或宿主机的的代理服务
  # 部署完我的nixos配置后，将会有qv2ray服务，可以用虚拟机的代理服务
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  # 取消以下注释以开启grub支持
  # boot.loader.grub.device = "/dev/sda";
  # 取消防火墙，以便kdeconnect正常运行
  # networking.firewall.enable = false;
nixos-install
reboot
```

### 物理机中安装NixOS（UEFI）

TODO: 暂时未探究命令行连接wifi的方法？所以目前使用gnome版ISO，而非minimal ISO。

下载gnome ISO镜像：https://nixos.org/download.html

启动U盘制作

```bash
sudo dd if=<path/to/nixos.iso> of=</dev/your_usb>
sync
```

注：需要在BIOS中取消secure boot，否则U盘无法启动。

参考官方的步骤[NixOS - NixOS 21.11 manual](https://nixos.org/manual/nixos/stable/#sec-installation)安装，使用UEFI，如下

安装nixos到物理机的/dev/sda

```bash
sudo bash
mkfs.ext4 -L nixos /dev/sda1
mkswap -L swap /dev/sda2
swapon /dev/sda2
mkfs.fat -F 32 -n boot /dev/sda3        # (for UEFI systems only)
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot                      # (for UEFI systems only)
mount /dev/disk/by-label/boot /mnt/boot # (for UEFI systems only)
nixos-generate-config --root /mnt
nano /mnt/etc/nixos/configuration.nix # 修改如下
  # 修改名字networking.hostName
  # 取消以下注释以开起代理
  # 将代理设置为自己的服务器
  # 安装过程中需要借助别的计算机的代理服务
  # 部署完我的nixos配置后，将会有qv2ray服务，可以用自己电脑的代理服务
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  # 取消以下注释以开启UEFI的支持
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # 添加
  boot.loader.grub.device = "nodev";
  boot.loader.systemd-boot.enable = true;
  # 取消防火墙，以便kdeconnect正常运行
  # networking.firewall.enable = false;
nixos-install
reboot
```

#### 双系统

仅测试了NixOS-Windows双系统。
在/mnt/etc/nixos/configuration.nix中添加

```
boot.loader.grub.useOSProber = true;
```

## 部署我的nixos配置

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

## [TODO]部分软件配置思路

### x11 gnome桌面

gnome extensions、gnome的快捷键等，通过dconf配置

### qv2ray科学上网

### vim支持的不好，用neovim代替

nixpkgs未支持的vim插件，通过buildVimPlugin添加

### 输入法使用fcitx

### autokey自动键盘脚本

### 使用docker提供ubuntu命令行环境

