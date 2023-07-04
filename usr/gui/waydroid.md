---
layout: default
title: Waydroid
date: 2023-02-04
parent: usr/gui
---

```nix
virtualisation.waydroid.enable = true;
```

尝试使用weston，消息来源参考：

* https://github.com/waydroid/waydroid/issues/470
  * https://wiki.archlinux.org/title/Waydroid

wayland images: `/var/lib/waydroid/images/`

```bash
weston --scale=2

# 在weston里
waydroid show-full-ui
```

weston快捷键参考`man weston-bindings`
