<div style="text-align:right; font-size:3em;">2022.05.29</div>

# 静态链接，以qemu为例

太长不看

* 实现了qemu静态链接，无任何动态链接库的依赖。
  采用了两个版本的qemu，当前版本Nix的qemu（nix 21.11, qemu 6.1.1）
  和qemu3.1.0这两个版本。
* nix脚本：[pkgs_qemu_static.nix](https://github.com/xieby1/xieby1.github.io/blob/main/src/scripts/nix/pkgs_qemu_static.nix)

## pkgsStatic及其源代码

Nixpkgs含有pkgsStatic软件包，但是大多软件无法直接使用。
需要进行手动修复。

pkgsStatic加载过程的源码

* pkgs/top-level/stage.nix
  将crossSystem设置为static且abi为musl。
  之所以用Musl是因为，

  > Currently uses Musl on Linux (couldn’t get static glibc to work).

  其代码大致的如下，
  ```nix
  pkgsStatic = nixpkgsFun {
    crossSystem = {
      isStatic = true;
      parsed = stdenv.hostPlatform.parsed // {
        abi = musl;
  };};};
  ```
  * nixpkgsFun = newArgs: import pkgs/top-level/default.nix (...)
    * pkgs/top-level/default.nix: stdenvStages {..., crossSystem, ...}
      * pkgs/stdenv/default.nix: stagesCross
        * pkgs/stdenv/cross/default.nix: stdenvAdapters.makeStatic
          * pkgs/stdenv/adapters.nix: makeStatic
            * makeStaticLibraries
              * 添加configureFlags "--enable-static" "--disable-shared"
              * 添加cmakeFlags "-DBUILD_SHARED_LIBS:BOOL=OFF"
              * 添加mesonFlags "-Ddefault_library=static"
            * makeStaticBinaries
              * 添加NIX_CFLAGS_LINK "-static"
              * 添加configureFlags "--disable-shared"

TODO: 读懂makeStaticLibraries和makeStaticBinaries。

## 基本思路

对于当前版本的qemu，使用pkgsStatic.qemu
，挨个修复编译报错即可。


对于历史版本的qemu，以3.1.0为例，编译方式已和现在有区别，
比如之前完全是configure, make，而现在引入了meson。
初步设想两种方案，

1. 嫁接老版本nixpkgs到当前版本
  将qemu-3.1.0对应的nixpkgs嫁接到当前的nixpkgs
2. 改造新版本nixpkgs以适应老版本
  通过overlay,override方法修改当前nixpkgs的qemu的nix表达式

我采用的第一种办法，将老版本nixpkgs嫁接到当前版本nixpkgs。
使用[lazamar.co.uk/nix-versions](https://lazamar.co.uk/nix-versions)
查询支持qemu-3.1.0的nixpkgs版本。
引入qemu-3.1.0的示例代码如下，详细见[pkgs_qemu_static.nix](https://github.com/xieby1/xieby1.github.io/blob/main/src/scripts/nix/pkgs_qemu_static.nix)

```nix
# get old nixpkgs which contains qemu-3.1.0
oldNixpkgsSrc = builtins.fetchTarball {...}
qemu31 = pkgs.callPackage (
  oldNixpkgsSrc + "/pkgs/applications/virtualization/qemu/default.nix"
) {...}
```

然后挨个修复编译报错即可。

## 调试手段

### 还原构建环境

```bash
# 保留构建失败的现场
nix-build pkgs_qemu_static.nix -K
```

进入现场包含env-vars文件和失败时的源码文件夹。
恢复环境，

```bash
. ./env-vars
. $stdenv/setup
```

### 查看依赖树

```bash
nix-store --query --tree <xxx.drv>
```

### 结果

目前仅需要命令行的qemu，因此为了省事，
我去掉了声音和图像支持。

注：在NixOS 21.11上和在ubuntu 22配合nix上编译出来的qemu二进制文件一模一样。

<pre><font color="#4E9A06"><b>xieby1@yoga14s</b></font>:<font color="#3465A4"><b>~</b></font>
<font color="#4E9A06"><b>$</b></font> pkgs_qemu_static.nix 
/nix/store/gs6plgyc0jr9i5qams0ifksijnq9hkq2-qemu-static-x86_64-unknown-linux-musl-6.1.1
/nix/store/lm9kl1nm7bs4hy6l4qng03k4srx1x28n-qemu-3.1.0-x86_64-unknown-linux-musl
<font color="#4E9A06"><b>xieby1@yoga14s</b></font>:<font color="#3465A4"><b>~</b></font>
<font color="#4E9A06"><b>$</b></font> ldd result/bin/qemu-system-x86_64 
	not a dynamic executable
<font color="#4E9A06"><b>xieby1@yoga14s</b></font>:<font color="#3465A4"><b>~</b></font>
<font color="#4E9A06"><b>$</b></font> result/bin/qemu-system-x86_64 --version
QEMU emulator version 6.1.1
Copyright (c) 2003-2021 Fabrice Bellard and the QEMU Project developers
<font color="#4E9A06"><b>xieby1@yoga14s</b></font>:<font color="#3465A4"><b>~</b></font>
<font color="#4E9A06"><b>$</b></font> ldd result-2/bin/qemu-system-x86_64 
	not a dynamic executable
<font color="#4E9A06"><b>xieby1@yoga14s</b></font>:<font color="#3465A4"><b>~</b></font>
<font color="#4E9A06"><b>$</b></font> result-2/bin/qemu-system-x86_64  --version
QEMU emulator version 3.1.0
Copyright (c) 2003-2018 Fabrice Bellard and the QEMU Project developers</pre>

