---
layout: default
title: Typora
parent: usr/gui
---

采用nixpkgs支持的最后的typora版本，即0.9.98。

```nix
mytypora = (pkgs.callPackage (pkgs.fetchurl {
  url = "https://raw.githubusercontent.com/NixOS/nixpkgs/137f19d1d48b6d7c7901bb86729a2bce3588d4e9/pkgs/applications/editors/typora/default.nix";
  sha256 = "057dk4hl4fljn50098g7l35sh7gwm7zqqqlrczv5lhmpgxi971c1";
}) {}).overrideAttrs (old: {
  src = pkgs.fetchurl {
    url = "https://web.archive.org/web/20211222112532/https://download.typora.io/linux/typora_0.9.98_amd64.deb";
    sha256 = "1srj1fdcblfdsfvdnrqnwsxd3y8qd1h45p4sf1mxn6hr7z2s6ai6";
  };
});
```

注：我尝试打包0.11.18，
发现这个版本会检测文件完整性，
因此基本上没办法用nix进行二次打包。

