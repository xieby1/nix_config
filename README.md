# xieby1的Nix/NixOS配置

该仓库存放着我的Nix/NixOS配置。
该仓库使用nix expression，而非nix flakes。
该仓库使用NixOS稳定源（目前版本22.11），而非非稳定源（unstable）。
该仓库的配置多平台都可以正常使用，

* NixOS: QEMU✅，NixOS单系统✅，NixOS+Windows双系统✅
* Nix: Linux✅，安卓（nix-on-droid）✅，WSL2✅

你可以使用该仓库的配置，配置出完整NixOS操作系统。
也可以使用其中的部分包、模块，扩充自己的Nix/NixOS。
若你不仅只是想安装Nix/NixOS，还想了解更多Nix/NixOS的知识，
欢迎看看我的关于Nix/NixOS的博客[xieby1.github.io/Distro/Nix/](https://xieby1.github.io/Distro/Nix/)。

## 目录

<!-- vim-markdown-toc GFM -->

* [文件夹结构](#文件夹结构)
* [使用方法](#使用方法)
* [软件配置思路](#软件配置思路)
  * [X11 Gnome桌面](#x11-gnome桌面)
    * [新增模块mime.nix](#新增模块mimenix)
  * [Windows程序（wrapWine）](#windows程序wrapwine)
  * [网页应用](#网页应用)
  * [Systemd用户服务](#systemd用户服务)
  * [Clash科学上网](#clash科学上网)
  * [Tailscale](#tailscale)
  * [Non-NixOS bash-completion](#non-nixos-bash-completion)
  * [Neovim](#neovim)
  * [Typora](#typora)
  * [输入法](#输入法)
  * [chroot or docker](#chroot-or-docker)
  * [TODO: terminal](#todo-terminal)

<!-- vim-markdown-toc -->

## 文件夹结构

* system.nix: 系统总体配置（nixos-rebuild的配置）
  * sys/cli.nix: 系统命令行配置
  * sys/gui.nix: 系统图形配置
* home.nix: 用户总体配置（home-manager的配置）
  * usr/cli.nix: 用户命令行配置
  * usr/gui.nix: 用户图形配置
* nix-on-droid.nix: 安卓总体配置（配合home-manager的配置）

## 使用方法

安装Nix/NixOS不在此赘述，参考https://nixos.org/download.html。

首先下载我的配置

```bash
git clone https://github.com/xieby1/nix_config.git ~/.config/nixpkgs
# [仅NixOS] 在imports中添加system.nix的路径
vim /etc/nixos/configuration.nix
```

然后设置软件源，在NixOS中推荐使用`sudo`。

```bash
# 替换为清华的最新稳定源
# [对于NixOS]
nix-channel --add https://mirror.tuna.tsinghua.edu.cn/nix-channels/nixos-22.11 nixos
# [对于Nix]
nix-channel --add https://mirror.tuna.tsinghua.edu.cn/nix-channels/nixos-22.11 nixpkgs
# 添加home manager源
nix-channel --add https://github.com/nix-community/home-manager/archive/release-22.11.tar.gz home-manager
nix-channel --update
```

最后部署配置

```bash
# [仅NixOS]
sudo nixos-rebuild switch
# 安装home-manager
nix-shell '<home-manager>' -A install
home-manager switch
```

## 软件配置思路

### X11 Gnome桌面

我使用的部分软件依赖于x11，在wayland中无法运行，因此选用x11。
在wayland足够成熟前，仍然保持x11。

#### 新增模块mime.nix

该模块用于配置文件类型和默认打开程序。
通过xdg-mime实现类型设置和默认程序设置。
例如默认使用xdot打开.dot结尾的文件，
详细见`usr/gui/mime.nix`。

### Windows程序（wrapWine）

详细见`usr/gui/wrapWine.nix`和`usr/gui/weixin.nix`。
以Windows微信为例，使用方法：

```nix
let
  weixin = import (builtins.fetchurl "https://raw.githubusercontent.com/xieby1/nix_config/main/usr/gui/weixin.nix") {
    wrapWine = import (builtins.fetchurl "https://raw.githubusercontent.com/xieby1/nix_config/main/usr/gui/wrapWine.nix") {};
  };
in
weixin
```

### 网页应用

TODO: singleton webapp

TODO: wrapWebApp

使用Chrome系列浏览器的`--app="URL"`来实现网页应用。
通过xdotool保证有且仅有一个网页应用被打开。
详细见`usr/gui/singleton_web_apps.nix`。

### Systemd用户服务

TODO:

使用systemd的用户服务(user service)，
这使得在非NixOS平台也能正常使用服务。

### Clash科学上网

命令行clash+网页控制，
这样的组合方便WSL和nix-on-droid这类无图形界面的使用场景。

添加了systemd user服务，详见`./usr/cli.nix: systemd.user.services.clash`的定义。
使用网页http://clash.razord.top来管理clash。
网页应用的定义见`./usr/gui/singleton_web_apps.nix`。

### Tailscale

TODO:

### Non-NixOS bash-completion

TODO:

### Neovim

所有的vim配置都在`usr/cli/vim.nix`中。

### Typora

使用方法见`usr/gui.nix: mytypora`的定义。
采用nixpkgs支持的最后的typora版本，即0.9.98。

注：我尝试打包0.11.18，
发现这个版本会检测文件完整性，
因此基本上没办法用nix进行二次打包。

### 输入法

沿用ubuntu的使用习惯，采用fcitx。
* 中文：cloudpinyin（支持模糊音、自动联网词库）
* 日文：mozc
* 韩文：hangul

### chroot or docker

TODO: podman, conenv.sh

chroot需要挂载诸多目录，才能使ubuntu正常运行。
但是NixOS并不提供FHS需要的众多目录。

因此使用docker提供ubuntu命令行环境。

### TODO: terminal
