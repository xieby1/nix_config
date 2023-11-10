<div style="text-align:right; font-size:3em;">2022.05.11</div>

# 安装deb包，以飞书为例

**太长不看**

* nix文件: https://github.com/xieby1/nix_config/blob/main/usr/gui/feishu.nix
* 使用方法:
  ```nix
  home.packages = with pkgs; [
    (callPackage ./feishu.nix {})
  ];
  ```

参考nixpkgs/pkgs/applications/networking/instant-messengers/skypeforlinux/default.nix

## 测试环境

nix-build -E "with import <nixpkgs> {}; callPackage ./default.nix {}"

## 权限问题

nix-build遇到dpkg -x解压失败。
但是手动执行dpkg -x一切正常。

https://unix.stackexchange.com/questions/138188/easily-unpack-deb-edit-postinst-and-repack-deb

确认是权限问题的实验

是s权限的问题。
nix-build下不能添加s权限。
原因未知

复现方法

```bash
touch $out/miao
chmox +s $out/miao
ls -l $out/miao
```

解决方法，使用fakeroot.

## 补全库

使用ldd脚本，获取所有elf所需的库，挨个添加进rpath即可。

## 桌面

application/*.desktop
menu/*.menu // 负责图标

