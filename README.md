---
layout: default
title: Home
nav_order: 1
permalink: /
---

# xieby1的Nix/NixOS配置

该仓库存放着我的Nix/NixOS配置。
该仓库使用nix expression，而非nix flakes。
该仓库使用NixOS稳定源（目前版本23.05），而非非稳定源（unstable）。
该仓库的配置多平台都可以正常使用，

* NixOS: QEMU✅，NixOS单系统✅，NixOS+Windows双系统✅
* Nix: Linux✅，安卓（nix-on-droid）✅，WSL2✅

你可以使用该仓库的配置，配置出完整NixOS操作系统。
也可以使用其中的部分包、模块，扩充自己的Nix/NixOS。
若你不仅只是想安装Nix/NixOS，还想了解更多Nix/NixOS的知识，
欢迎看看这个仓库的文档[xieby1.github.io/nix_config](https://xieby1.github.io/nix_config)。

## 目录

<!-- vim-markdown-toc GFM -->

* [文件夹结构](#文件夹结构)
* [Nix和NixOS的关系](#nix和nixos的关系)
* [使用场景](#使用场景)
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
  * [输入法](#输入法)
  * [chroot or docker](#chroot-or-docker)
  * [TODO: terminal](#todo-terminal)
* [引用](#引用)

<!-- vim-markdown-toc -->

## 文件夹结构

* system.nix: 系统总体配置（nixos-rebuild的配置）
  * sys/cli.nix: 系统命令行配置
  * sys/gui.nix: 系统图形配置
* home.nix: 用户总体配置（home-manager的配置）
  * usr/cli.nix: 用户命令行配置
  * usr/gui.nix: 用户图形配置
* nix-on-droid.nix: 安卓总体配置（配合home-manager的配置）

## Nix和NixOS的关系

Nix是一个先进的包管理系统，用来管理软件包。
其目标和常见的apt、rpm等包管理器一致。
相对于这些包管理器，Nix采用了纯函数构建模型、使用哈希存储软件包等思想。
这使得Nix能够轻松做到做到可重现构建、解决依赖地狱（dependency hell）。
Nix源自于Dolstra博士期间的研究内容。
其详细理论由他的博士论文[^doc_thesis]支撑。

NixOS则是把整个Linux操作系统看作一系列软件包（包括内核），采用Nix来进行管理。
换句话说，NixOS是一个的使用Nix包管理器的Linux发行版。

你可以单独使用Nix包管理器，用它来管理你的用户程序。
你也可以使用NixOS，让你的整个操作系统都由Nix管理。
Nix/NixOS带来的最直观的优势就是，只要保留着Nix/NixOS的配置文件，
就能恢复出一个一模一样的软件环境/操作系统。
（当然这是理想情况下。
nix 2.8的impure特性，home-manager等在打破这一特性。
不过不用担心。
只要保留配置文件，Nix/NixOS上能够生成一个几乎一模一样的软件环境/操作系统）

至此你可能会产生疑问，Nix/NixOS能够管理系统、软件及其配置，那数据呢？
虽然Nix/NixOS不直接管理数据，但是Nix/NixOS可以很好的管理数据同步软件。
比如使用开源软件Syncthing，或是开源服务NextCloud，或是商业服务Google Drive。
因此只要有Nix/NixOS的配置文件，
那就能轻松的构建出包含你熟悉的软件、配置、数据的软件环境/操作系统啦。

我的Nix/NixOS配置存放在这里
[github.com/xieby1/nix_config](https://github.com/xieby1/nix_config)。

## 使用场景

* 重装系统：复原老系统的环境
* 双系统：让WSL和Linux保持相同的环境
* 虚拟机：让本地环境和虚拟机保持相同的环境
* 容器：让本地环境和容器保持相同的环境
* 多设备：让多台电脑/手机[^nix-on-droid]保持相同的环境

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
nix-channel --add https://mirror.tuna.tsinghua.edu.cn/nix-channels/nixos-23.05 nixos
# [对于Nix]
nix-channel --add https://mirror.tuna.tsinghua.edu.cn/nix-channels/nixos-23.05 nixpkgs
# 添加home manager源
nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz home-manager
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

## 引用

[^doc_thesis]: Dolstra, Eelco. “The purely functional software deployment model.” (2006).

[^nix-on-droid]: [github.com/t184256/nix-on-droid](https://github.com/t184256/nix-on-droid) termux的分支，支持nix
