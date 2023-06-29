---
layout: default
title: Nodejs
parent: usr/cli
date: 2022-09-07
---

# Nodejs packages (npm) in NixOS

# NixOS中的Nodejs包（npm）

太长不看：手动暴露`buildNodePackage`，添加自定义的npm包。

nixpkgs中的node包虽多但有限，
遇到需要的node包不存在时，是个麻烦事。

让我觉得十分诡异的是，
nixpkgs中存在一个十分方便的添加node包的函数`nodeEnv.buildNodePackage`，
但是这个函数却不暴露出来给用户。
甚至，有些nixpkgs中的包为了使用这个函数，
复制粘贴该函数到自己的包中。

在这些奇怪的事情的基础上，
还衍生出来自动生成该`buildNodePackage`函数软件`node2nix`。

所以这真的是存在即合理嘛？
还是我学艺不精，不能理解设计者的意图？

一个简单的暴露`buildNodePackage`的方法，
直接导入`buildNodePackage`所在的文件。
为了跨平台可用，
路径的构建采用了一点使用了点点小把戏，

```nix
<nixpkgs> + /pkgs/development/node-packages/node-env.nix
```

以@types/node为例子，nodepkgs.nix：

```nix
{ ... }:
let
  pkgs = import <nixpkgs> {};
  nodeEnv = import (<nixpkgs> + /pkgs/development/node-packages/node-env.nix) {
    inherit (pkgs) lib stdenv nodejs python2;
    inherit pkgs;
    inherit (pkgs) libtool runCommand writeTextFile writeShellScript;
  };
  globalBuildInputs = [];
in {
  "@types/node" = nodeEnv.buildNodePackage {
    name = "_at_types_slash_node";
    packageName = "@types/node";
    version = "18.7.15";
    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@types/node/-/node-18.7.15.tgz";
      sha512 = "XnjpaI8Bgc3eBag2Aw4t2Uj/49lLBSStHWfqKvIuXD7FIrZyMLWp8KuAFHAqxMZYTF9l08N1ctUn9YNybZJVmQ==";
    };
    buildInputs = globalBuildInputs;
    meta = {
      description = "TypeScript definitions for Node.js";
      homepage = "https://github.com/DefinitelyTyped/DefinitelyTyped/tree/master/types/node";
      license = "MIT";
    };
    production = true;
    bypassCache = true;
    reconstructLock = true;
  };
}
```

该nodepkgs.nix文件为用户自定义的node包，
可以像nixpkgs一样使用这个文件，例如导入

```nix
myNodePkgs = import ./cli/nodepkgs.nix {}
```

包的表达式为`myNodePkgs."@types/node"`。
