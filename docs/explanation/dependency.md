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

* [Dependency propagation](https://nixos.org/manual/nixpkgs/unstable/#ssec-stdenv-dependencies-propagated)

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
