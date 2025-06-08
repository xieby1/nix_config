🏗️ *我的Nix/NixOS配置详细文档正在施工中，完成进度：<span style="font-size:2em;">**39/105**</span>* 🏗️

为了更好的文档阅读体验，请看[GitHub Pages](https://xieby1.github.io/nix_config/)的版本。

## 目录

<!-- vim-markdown-toc GFM -->

* [Nix/NixOS简介](#nixnixos简介)
* [xieby1和Nix/NixOS](#xieby1和nixnixos)
* [xieby1的Nix/NixOS配置](#xieby1的nixnixos配置)
  * [文件夹结构](#文件夹结构)
  * [nix脚本的使用方法](#nix脚本的使用方法)
    * [nix-shell的例子](#nix-shell的例子)
  * [nix配置的使用方法](#nix配置的使用方法)
  * [引用](#引用)

<!-- vim-markdown-toc -->

# Nix/NixOS简介

Nix是一个可重现的（Reproducible）包管理器，也是一门纯函数式的（Pure Functional）编程语言。
理论上讲，Nix包管理器可以安装在任何Linux发行版上(比如Ubuntu、Debian和Arch等)，并与这些发行版原有的包管理器（比如snap、apt和pacman等）共存。
而NixOS则是完全由Nix包管理器进行管理的Linux发行版。

Nix/NixOS采用了“包（Package）”的理念，将Linux内核、驱动、函数库、用户程序、配置文件等方方面面抽象出来。
这类似于Linux内核将设备、磁盘文件、管道等都抽象为文件的理念。
这样的抽象使得Nix/NixOS能以一种统一的方式管理所有的包。

为了防止“包”被用户有意或无意地修改（即保证可重现性），Nix/NixOS将所有的包都放在一个只读文件系统中（挂载在`/nix/store`目录上）。
这个目录中的包仅能通过Nix包管理器和Nix语言编程进行增删改。
为了将`/nix/store`中的文件放置在它们应该在的地方（比如某个用户使用的包里存在`bin/`目录，则应当把bin/中所有的文件放入`/run/current-system/sw/bin/`），Nix/NixOS大量使用符号链接。

上述Nix/NixOS的特点和传统Linux发行版有着极大的区别。
这使得Nix/NixOS的学习曲线十分陡峭。
不过当你适应Nix/NixOS的这些特点后，它可以极大提升工程效率!

# xieby1和Nix/NixOS

多年来，Nix/NixOS已成为我学习和工作的重要基础，主要用于以下方面：

* 学习Linux。
  Nix/NixOS采用了“包（Package）”的理念，将Linux内核、驱动、函数库、用户程序、配置文件等方方面面抽象出来。
  通过学习Nix语言，我能够以统一的方式了解Linux系统的各个方面，这是其他工具所无法提供的。
* 管理环境。
  通过使用nix-shell管理所有依赖（包括库、环境变量、配置等），可以避免项目环境重现的问题。
  类似的工具还有虚拟机和Docker。
  相比使用虚拟机，它更轻量。
  相比Docker，它支持可复现构建，采用Nix语言更灵活。
  详细可见我于2023年为实验室同学们准备的[推荐Nix/NixOS的幻灯片](https://xieby1.github.io/nix_config/docs/slides/2023.nix-env.html)。
* 备份电脑。
  Nix/NixOS能够管理系统、软件及其配置。
  虽然Nix/NixOS不直接管理数据，但Nix/NixOS可以很好地管理数据同步软件，比如Syncthing。
  因此只要保留着Nix/NixOS的配置文件（由Nix语言编写），就能恢复出一个几乎一模一样[^impure]的软件环境/操作系统。

# xieby1的Nix/NixOS配置

这个仓库[Github: xieby1/nix_config](https://github.com/xieby1/nix_config)里存放着我的Nix/NixOS配置和文档。
该仓库使用nix expression，而非nix flakes；
使用NixOS稳定源（目前版本25.05），而非非稳定源（unstable）。
该仓库的配置在多个平台都可以正常使用：

* NixOS: QEMU✅，NixOS单系统✅，NixOS+Windows双系统✅
* Nix: Linux✅，安卓（nix-on-droid）✅，WSL2✅

你可以使用该仓库的配置，配置出完整NixOS操作系统。
也可以使用其中的部分包、模块，扩充自己的Nix/NixOS。
若你不仅只是想安装Nix/NixOS，还想了解更多Nix/NixOS的知识，
欢迎看看这个仓库的文档[xieby1.github.io/nix_config](https://xieby1.github.io/nix_config)。

## 文件夹结构

* docs/: 文档
* scripts/: nix脚本
  * fhs-shell/: 采用FHS的nix-shell脚本
  * shell/: nix-shell脚本
  * pkgs/: 独立的软件包脚本
* sys/: 系统总体配置（nixos-rebuild的配置）
  * cli/: 系统命令行配置
  * gui/: 系统图形配置
  * modules/: 系统模块
* home.nix: 用户总体配置（home-manager的配置）
  * usr/cli/: 用户命令行配置
  * usr/gui/: 用户图形配置
  * modules/: 用户模块
* nix-on-droid.nix: 安卓总体配置（nix-on-droid的配置）
* modules/: nixos/home-manager通用的模块

## nix脚本的使用方法

安装Nix不在此赘述，参考[nixos.org/download.html](https://nixos.org/download.html)。

安装完Nix后，下载所需的nix脚本，然后：

* `fhs-shell/`和`shell/`脚本用`nix-shell`命令进入shell环境；
* `pkgs/`脚本用`nix-build`命令生成软件包。

### nix-shell的例子

```bash
# 以xiangshan.nix配置香山开发环境为例
# 进入香山的根目录
cd Xiangshan
# 下载xiangshan.nix脚本，并重命名为shell.nix
wget https://raw.githubusercontent.com/xieby1/nix_config/main/scripts/shell/xiangshan.nix -O shell.nix
# 进入nix shell
nix-shell
```

## nix配置的使用方法

虚拟机/物理机单系统/物理机双系统 安装NixOS 可以参考我两年前的[NixOS安装](./docs/howto/install_nixos.html)过程。
安装Nix/NixOS不在此赘述，参考[nixos.org/download.html](https://nixos.org/download.html)。

安装完Nix/NixOS后，首先下载我的配置

```bash
git clone https://github.com/xieby1/nix_config.git ~/.config/nixpkgs
# [仅NixOS] 在imports中添加sys/的路径
vim /etc/nixos/configuration.nix
```

然后设置软件源，在NixOS中推荐使用`sudo`。

* 注一：更多其他nix channels参考
  [NixOS Wiki: Nix channels](https://nixos.wiki/wiki/Nix_channels)
  和[Nix channel status](https://status.nixos.org/)。
* 注二：为什么用https://nixos.org/channels/nixos-25.05，
  而非https://github.com/NixOS/nixpkgs/archive/release-25.05.tar.gz？
  前者包含额外内容，比如programs.command-not-found.dbPath，详细见`man configuration.nix`。

```bash
# [对于NixOS]
nix-channel --add https://nixos.org/channels/nixos-25.05 nixos
# [对于Nix]
nix-channel --add https://nixos.org/channels/nixos-25.05 nixpkgs
# 添加home manager源
nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz home-manager
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

## 引用

[^impure]: nix 2.8的impure特性和home-manager等会引入一些你几乎察觉不到的差异。

[^doc_thesis]: Dolstra, Eelco. “The purely functional software deployment model.” (2006).

[^nix-on-droid]: [github.com/t184256/nix-on-droid](https://github.com/t184256/nix-on-droid) termux的分支，支持nix。
