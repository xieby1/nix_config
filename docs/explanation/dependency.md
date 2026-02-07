信息来源：`<nixpkgs>/doc/stdenv/stdenv.chapter.md`和nixpkgs源码

# Describing Dependency

这一部分的内容总结: 说明stdenv里6个描述依赖的变量
depsBuildBuild, nativeBuildInputs, depsBuildTarget, depsHostHost, buildInputs, depsTargetTarget。

* [Packaging in a cross-friendly manner](https://nixos.org/manual/nixpkgs/unstable/#sec-cross-packaging)

> Nixpkgs follows the conventions of GNU autoconf.
> We distinguish between 3 types of platforms when building a derivation: build, host, and target.
> In summary, build is the platform on which a package is being built,
> host is the platform on which it will run.
> The third attribute, target, is relevant only for certain specific compilers and build tools.

* [Theory of dependency categorization](https://nixos.org/manual/nixpkgs/unstable/#ssec-cross-dependency-categorization)

>  Possible dependency types
>
> | Dep type        | Dep’s host platform | Dep’s target platform |
> |-----------------|---------------------|-----------------------|
> | build → *       | build               | (none)                |
> | build → build   | build               | build                 |
> | build → host    | build               | host                  |
> | build → target  | build               | target                |
> | host → *        | host                | (none)                |
> | host → host     | host                | host                  |
> | host → target   | host                | target                |
> | target → *      | target              | (none)                |
> | target → target | target              | target                |

所有这些视角是我们要编译的包它看到的，相对它而言的，build、host、target是指它的build、host、target平台

删掉了三个*，看来是

* `build->*`被`build->host`(nativeBuildInputs)代替了
* `host->*`被`host->target`(buildInputs)代替了
* `target->*`，*仅包含(none)和target，被`target->target`代替了

> | host → target     | attribute name    | offset |
> |-------------------|-------------------|--------|
> | build --> build   | depsBuildBuild    | -1, -1 |
> | build --> host    | nativeBuildInputs | -1, 0  |
> | build --> target  | depsBuildTarget   | -1, 1  |
> | host --> host     | depsHostHost      | 0, 0   |
> | host --> target   | buildInputs       | 0, 1   |
> | target --> target | depsTargetTarget  | 1, 1   |

# Propagating Dependency

* [Dependency propagation](https://nixos.org/manual/nixpkgs/unstable/#ssec-stdenv-dependencies-propagated)

这一部分的内容总结：
* 说明stdenv里6个描述**直接**传递依赖的变量
  depsBuildBuildPropagated, propagatedNativeBuildInputs, depsBuildTargetPropagated,
  depsHostHostPropagated, propagatedBuildInputs,
  depsTargetTargetPropagated。
* 说明所有**直接+间接**（传递闭包）依赖的变量在stdenv/setup里的变量
  pkgsBuildBuild, pkgsBuildHost, pkgsBuildTarget,
  pkgsHostHost, pkgsHostTarget,
  pkgsTargetTarget。

## Propagating Algorithm

总结：
Nix文档并未说明这个算法的普适性。（这个等未来有需求了再考虑吧）
这个算法的一些特殊情况确实是符合直觉的。

### 问题描述

* X依赖Y，Y依赖Z。其中依赖通过上一节的6个变量描述。这样没啥问题。
* 若现在X依赖Y，Y传递依赖Z。那X对Z的依赖怎么描述？

符号化上面的问题：

* X依赖Y <=> `dep(h, t, X, Y)`，其中h和t为X依赖Y的类型所决定的host/target offset，见上一节的表格
  * 例子`X.nativeBuildInputs = [Y]` => `dep(-1, 0, X, Y)`
* X传递依赖Y <=> `propagated-dep(h, t, X, Y)`
  * 例子`X.depsBuildTargetPropagated = [T]` => `propagated-dep(-1, 1, X, Y)`
* 注：为什么上面的推导符号用的是=>而不是<=>？
  * 因为nix里描述依赖的6+6个变量是描述的直接依赖，而未包含间接（传递得到的）依赖。
    即存在`dep(h, t, X, Y)`但`X.xxx = [...]`里未包含Y的情况。
    * 你想知道什么变量里记录着所有（直接+间接）依赖？
      往下看，在pkgs{Build/Host/Target}{Build/Host/Target}里。
      这些变量需要stdenv的setup阶段得到。
* 则符号化描述：
  * 已知`dep(h_xy, t_xy, X, Y)`, `propagated-dep(h_yz, t_yz, Y, Z)`
  * 求`dep(h_xz, t_xz, X, Z)`

nix给出的算法：
* `h_xz = mapOffset(h_xy, t_xy, h_yz)`
* `t_xz = mapOffset(h_xy, t_xy, t_yz)`

#### 我的逻辑分析

* 已知：dep(h_xy, t_xy, X, Y)
* Y视角下3个平台：b_y(-1), h_y(0), t_y(1)到X视角下的平台的映射关系：
  * b_y未知/没有啥逻辑？Y的build平台在X视角下没有任何意义才对。
    * 说人话，用X86-64原生编译的Y1和用AArch64交叉编译出的Y2，对于X都没影响才对。
    * 更进一步思考，Nix里上述两个包Y1和Y2其实是不一样的。这是不是源自于这里？
      * 这个未来再说吧
  * h_y -> h_xy：逻辑解读：字面意思而已。h_xy就是就是y的h（h_y）在X视角下的平台。
  * t_y -> t_xy：逻辑解读：字面意思而已。t_xy就是就是y的t（t_y）在X视角下的平台。

#### `mapOffset(h, t, i)`分析

* nix文档的定义`let mapOffset(h, t, i) = i + (if i <= 0 then h else t - 1)`
  * 这个公式写这么复杂，实属徒增代码阅读复杂度。其实就是下面3种情况（完全枚举）：
  * mapOffset(h_xy, t_xy, -1) = -1 + h_xy
    * b_y -> h_xy - 1
  * mapOffset(h_xy, t_xy,  0) = h_xy
    * h_y -> h_xy
  * mapOffset(h_xy, t_xy,  1) = t_xy
    * t_y -> t_xy
* 即符合我的逻辑分析。b_y -> h_xy - 1算是一个自然延伸。

## See How Propagating Algorithm Runs

上述传递算法的实际运作过程，在stdenv/setup（`<nixpkgs>/pkgs/stdenv/generic/setup.sh`）中。
核心代码框架精简如下（伪代码用了rust的高亮，实际是bash代码）：

```rust
findInputs(pkg, hostOffset, targetOffset) {
  // 往6个pkgsXXX变量中对应的一个里添加pkg
  // eval "$var"'+=("$pkg")'
  pkgs{Build/Host/Target}{Build/Host/Target} += pkg

  for pkgNext in 6个直接传递依赖变量里的包 {
    hostOffsetNext = mapOffset(h, t, relHostOffset)
    targetOffsetNext = mapOffset(h, t, relTargetOffset)
    // 自迭代
    findInputs(pkgNext, hostOffsetNext, targetOffsetNext)
  }
}
```

所以依赖图的遍历过程在stdenv/setup中findInputs函数完成。
遍历后得到所有依赖（直接依赖、间接依赖）放入了6个pkgs{Build/Host/Target}{Build/Host/Target}变量中。
还需要注意的是，依赖传递通过$pkg/nix-support/对应的文件propogate文件实现。

注：6个pkgs{Build/Host/Target}{Build/Host/Target}为**数组变量**，
* 若用$pkgs{Build/Host/Target}{Build/Host/Target}则仅显示第一个元素，这是bash的特性
  * 例：$pkgsHostTarget仅为第一个元素
* 需要用${pkgs{Build/Host/Target}{Build/Host/Target}[@]}才会显示所有元素。
  * 例：${pkgsHostTarget[@]}为所有元素
