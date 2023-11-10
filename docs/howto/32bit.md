# 打包/编译32位程序

参考[Packaging/32bit Applications](https://nixos.wiki/wiki/Packaging/32bit_Applications)。

## 仅32位

打包使用pkgs.pkgsi686Linux.stdenv.mkDerivation

编译使用pkgs.pkgsi686Linux.gcc

## 32位且64位

打包使用pkgs.multiStdenv.mkDerivation。

编译使用pkgs.gcc_multi。

