# Nixpkgs

## nixpkgs crossSystem

* default.nix
  * pkgs/top-level/impure.nix
    * pkgs/top-level/default.nix
      * lib.systems.elaborate crossSystem0;
        * lib/systems/default.nix: elaborate
          * parsed = parse.mkSystemFromString ... args.system; // args.system = crossSystem
            * lib/systems/parse.nix
              * mkSystemFromString = s: mkSystemFromSkeleton (mkSkeletonFromList (lib.splitString "-" s));
                * mkSkeletonFromList

注意mkSkeletonFromList通过
`${toString (length l)}`
实现了一个根据l长度的switch case。

crossSystem的4个域分别为cpu-vendor-kernel-abi

## import nixpkgs

`import <nixpgks> {}`
的加载流程

* default.nix
  * pkgs/top-level/impure.nix
    * pkgs/top-level/default.nix
      * stdenvStages import pkgs/stdenv/default.nix
        * stagesLinux = import pkgs/stdenv/linux/
          * thisStdenv, stdenv = import pkgs/stdenv/generic/default.nix
            * import lib/default.nix
              # this is where customisation.nix come from
      * allPackages import pkgs/top-level/stage.nix
        * allPackages import pkgs/top-level/all-packages.nix
      * boot = import pkgs/stdenv/booter.nix

vim_configurable.override {python = python3}
vimUtils.makeCustomizable (vim.override {python = python3})
vimUtils.makeCustomizable (vim.override {python = python3})

似乎是一个浮现override变量的最小集
f = a:{res = a+1;}
fo = pkgsMiao.makeOverride f
f 2
