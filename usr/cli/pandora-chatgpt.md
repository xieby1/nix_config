<div style="text-align:right; font-size:3em;">2023.05.03</div>

# 打包python（pip）包，以pandora-chatgpt为例

**太常不看**

* nix文件: https://github.com/xieby1/nix_config/blob/main/usr/cli/pandora-chatgpt.nix
* 使用方法：
  ```nix
  pkgs.python3Packages.callPackage ./cli/pandora-chatgpt.nix {};
  ```
* Add python optional dependencies (extras): see [nixpkgs manual](https://nixos.org/manual/nixpkgs/stable/) 17.27.2.3.2. Optional extra dependencies

