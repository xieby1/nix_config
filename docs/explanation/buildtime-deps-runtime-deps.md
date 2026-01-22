起因：local-typst-env将pkgsBuildTarget的方法换成了buildEnv。
仔细一项不对啊，pkgsBuildTarget是buildtime deps，buildEnv（本质是writeClosures）是runtime deps。
为何buildEnv也会生效呢？

仔细看了看，是因为`stdenv/setup.sh`把propagatedXXX都写入到了`$out/nix-support/propagated-xxx`。
即将buildtime deps转化为了runtime deps。

TODO：nix如何寻找runtime deps这个我没细看，依稀记得是扫描`$out`里的所有路径？

- DONE：去看看为什么`stdenv/setup.sh`要这么做？
  我还看到了不少packages里，为了避免传播错误，显式地`rm $out/nix-support/propagated-build-inputs`。
- 我去追踪了写`$out/nix-support/propagated-build-inputs`的历史，
  f1166e0bbbc5b (Eelco Dolstra 2006-08-07) 就引入了，所以这算是个是“特性”？
  若不想做自动buildtime deps => runtime deps转换，则手动删掉`$out/nix-support/propagated-xxx`即可？
- A: 因为`stdenv/setup.sh`运行的时候，已经获取不到derivation的信息了？所以得把`propagated-xxx`信息写入到`$out/`目录里
