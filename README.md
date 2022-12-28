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
    * [gnome桌面](#gnome桌面)
      * [Wayland or X11](#wayland-or-x11)
      * [新增模块mime.nix](#新增模块mimenix)
    * [科学上网](#科学上网)
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


### 科学上网

使用clash。
手动将机场提供clash的config.yaml放在`~/.config/clash/config.yaml`即可。

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
