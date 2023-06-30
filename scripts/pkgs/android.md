---
layout: default
title: Android App
parent: scripts/pkgs
---

<div style="text-align:right; font-size:3em;">2022.04.19</div>

# 在NixOS上使用Android程序

TLDR: 使用Android Studio提供的Android Emulator体验最好，其次是使用QEMU+x86Android。

<!-- vim-markdown-toc GFM -->

* [Anbox & Waydroid](#anbox--waydroid)
* [qemu + x86 Android](#qemu--x86-android)
* [Google Android Emulator](#google-android-emulator)
  * [获取apk package和activity](#获取apk-package和activity)
  * [avdmanager找不到镜像](#avdmanager找不到镜像)
  * [模拟器闪退](#模拟器闪退)
  * [debug 方法](#debug-方法)
  * [PCI bus not available for hda](#pci-bus-not-available-for-hda)
* [Google Android Studio](#google-android-studio)
* [redroid](#redroid)

<!-- vim-markdown-toc -->

## Anbox & Waydroid

Anbox & Waydroid属于将Android runtime移植到Linux上的项目。
都需要安装内核模块。

Anbox已未维护。

Waydroid需要Wayland支持。目前我还采用X11。

## qemu + x86 Android

虚拟机，没有找到图形和音频的加速方法。基本可用的程度。

* vanilla x86 android: OK
* lineageOS: OK
  * same to vanilla x86 android
  * wechat not work
* phoenixOS: stuck in booting

```bash
# 安装在运行命令后添加-cdrom </path/to/iso> -boot -d
# 运行命令
qemu-system-x86_64 -m 4G -smp 3 -hda ~/Img/andx64_vcm141r5.qcow2 -enable-kvm -display gtk,window-close=off -device AC97
```

注：-vga virtio不能启动图形界面，原因未探索。

## Google Android Emulator

使用nix提供的emulate-app.nix直接运行Google Android Emulator (魔改的QEMU)。

模拟器闪退无法启动，暂时没有尝试去解决。

参考

* https://nixos.wiki/wiki/Android
  * [2014: Reproducing Android app deployments (or playing Angry Birds on NixOS)](https://sandervanderburg.blogspot.com/2014/02/reproducing-android-app-deployments-or.html)
* [SO: Run Android app in qemu-arm?](https://stackoverflow.com/questions/24627978/run-android-app-in-qemu-arm)
  * [2014: Running Android L Developer Preview on 64-bit Arm QEMU](https://www.linaro.org/blog/running-64bit-android-l-qemu/index.html)

使用的nix脚本见android.nix

### 获取apk package和activity

aapt已经淘汰，现在使用的是[aapt2](https://developer.android.com/studio/command-line/aapt2#download_aapt2)，run by [nix-alien](https://github.com/thiagokokada/nix-alien)。
例子，

```bash
nix-alien aapt2 dump badging </path/to/apk>
```

### avdmanager找不到镜像

Error: Package path is not valid. Valid system image paths are:ository...

相关问题

* [GH: avdmanager create avd fails with "Probably the SDK is read-only" #154898](https://github.com/NixOS/nixpkgs/issues/154898)
  * [GH: androidenv.emulateApp fails to start emulator (libvulkan.so.1: full) #121146](https://github.com/NixOS/nixpkgs/issues/121146)
* [SO: error: package path is not valid. valid system image paths are:ository... null](https://stackoverflow.com/questions/66597053)

从pkgs/development/mobile/androidenv/compose-android-packages.nix看，
platformVersions, systemImageTypes, abiVersions需要和
pkgs/development/mobile/androidenv/repo.json
中的emulator项中的数据匹配。

看repo.json，而不是看`sdkmanager --list`，不一定有，但能看到已安装。

不匹配，在nix-build中不会报错，运行过程报上面的错误。

### 模拟器闪退

和问题类似[GH: androidenv.emulateApp fails to start emulator (libvulkan.so.1: full) #121146](https://github.com/NixOS/nixpkgs/issues/121146)

报错内容，没解决

```bash
cannot add library /nix/store/yz1p6cw09h3im4z7wmx7nshi054fzhw4-emulator-30.8.4/libexec/android-sdk/emulator/qemu/linux-x86_64/lib64/vulkan/libvulkan.so: failed
added library /nix/store/yz1p6cw09h3im4z7wmx7nshi054fzhw4-emulator-30.8.4/libexec/android-sdk/emulator/lib64/vulkan/libvulkan.so
emulator: WARNING: Ignoring invalid http proxy: Bad format: invalid port number (must be decimal)
Device state has been reached
LLVM ERROR: Cannot select: intrinsic %llvm.x86.sse41.pblendvb
```

### debug 方法

参考https://nixos.wiki/wiki/Nixpkgs/Create_and_debug_packages#How_to_install_from_the_local_repository

使用本地nixpkgs，修改，nix-shell看变量
例子：

```bash
nix-shell -E 'with import "/home/xieby1/temp-nixpkgs" {config.android_sdk.accept_license = true;}; (androidenv.composeAndroidPackages {includeSystemImages =true; platformVersions=["16"];}).androidsdk'
```

nix expression调用关系

* emulate-app.nix
  * compose-android-packages.nix
    * tools.nix
      * tools/26.nix
        * deploy-androidpackage.nix

### PCI bus not available for hda

https://stackoverflow.com/questions/69297141/android-11-emulator-gives-pci-bus-not-available-for-hda

修改./result/bin/run-test-emulator添加-qemu -machine virt到Launch the emulator的指令后

```bash
/nix/store/0q68cfq7rnbw752l89fkxf425v1pb2r6-androidsdk/libexec/android-sdk/emulator/emulator -avd device -no-boot-anim -port $port $NIX_ANDROID_EMULATORFLAGS -qemu -machine virt &
```

## Google Android Studio

使用Android Studio的AVD安装Android emulator最省心。

可以使用微信（公众号闪退），语音视频流畅，小游戏流畅。

## redroid

暂时没成功

文档并未提供和各个参数相关的源文件？
