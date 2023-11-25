#MC # opt.nix
#MC
#MC nix语言中只有`let ... in`来定义局部变量，没有提供全局变量的语法支持。
#MC 但在我的nix配置中又很需要一些“全局变量”来方便统一的管理多个配置文件。
#MC nixpkgs的module能够还不错地实现“全局变量”。
#MC 我的`opt.nix`即利用module的options定了多个可以供其他modules使用的全局变量。
#MC 想了解module？可以去看看[NixOS wikiL modules](https://nixos.wiki/wiki/NixOS_modules)。
#MC 或者看看nixpkgs源码关于modules.nix的部分`<nixpkgs>/lib/modules.nix`。
#MC
#MC 要注意的是，基于module的“全局变量”也会有<span style="color:red;">**局限**</span>的。
#MC module是用过imports变量导入的，若在imports语句访问“全局变量”，nix的lazy evaluation的特性会导致死循环。
#MC 这也是为什么[home.nix](./home.nix.md)中判断是否需要导入[./usr/gui.nix](./usr/gui.nix.md)，
#MC 我没有使用`config.isGui`而是再次使用getEnv访问环境变量。
#MC
#MC 下面是我的配置的全局变量及注解。

{ config, pkgs, stdenv, lib, ... }:

{ options = {
  #MC `proxyPort`：代理端口号，诸多网络程序需要用，比如clash和tailscale。
  proxyPort = lib.mkOption {
    default = 8889;
    readOnly = true;
  };
  #MC `isCli`和`isGui`：通过环境变量`DISPLAY`来判断是否是CLI或GUI环境。
  #MC 这个方法有<span style="color:red;">**局限**</span>，比如ssh连接到一台有GUI的电脑上，ssh里是没有设置环境变量`DISPLAY`的。
  #MC 若直接执行`home-manager switch`，则这台电脑上的GUI程序都会被禁用。
  #MC 缓解的方法也很简单，手动写个环境变量就好，比如`DISPLAY=1 home-manager switch`就OK啦😺。
  isCli = lib.mkOption {
    default = (builtins.getEnv "DISPLAY")=="";
    readOnly = true;
  };
  isGui = lib.mkOption {
    default = (builtins.getEnv "DISPLAY")!="";
    readOnly = true;
  };
  #MC `isNixOnDroid`：通过用户名来判断是否是nix-on-droid。
  isNixOnDroid = lib.mkOption {
    default = config.home.username == "nix-on-droid";
    readOnly = true;
  };
  #MC `isWSL2`：通过环境变量`WSL_DISTRO_NAME`来判断是否是WSL2。
  isWSL2 = lib.mkOption {
    default = (builtins.getEnv "WSL_DISTRO_NAME")!="";
    readOnly = true;
  };
};}
