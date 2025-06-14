#MC 用于自动push包到cachix的模块。
#MC 尽管cachix watch-store能自动push，但是我想更细粒度地管理需要push的包，所以有了这个模块。
{ config, pkgs, lib, ...}:

{
  options = {
    cachix_packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = ''
        This list of packages.

        If the the cachix.dhall file exists and cachix_packages is not empty,
        then the packages in cachix_packages will be pushed to cachix.
      '';
    };
    cachix_dhall = lib.mkOption {
      type = lib.types.str;
      default = "/home/xieby1/Gist/Config/cachix.dhall";
      description = ''
        The path of cachix.dhall.
      '';
    };
    cachix_name = lib.mkOption {
      type = lib.types.str;
      default = "xieby1";
      description = ''
        The cachix name.
      '';
    };
    _cachix_push = lib.mkOption {
      type = lib.types.str;
      default = ''
        mkdir -p ~/.config/cachix_push
        ${lib.concatMapStrings (pkg: ''
          symlink=~/.config/cachix_push/${pkg.name}
          if [[ ! (-h "$symlink" && $(realpath "$symlink")==${pkg}) ]]; then
            # the symlink are not the same to pkg, need to cachix push
            echo 📦 ${pkg}
            ${pkgs.cachix}/bin/cachix -c ${config.cachix_dhall} push ${config.cachix_name} ${pkg}
            rm -f "$symlink"
            ln -s ${pkg} "$symlink"
          fi
        '') config.cachix_packages}
      '';
      description = ''
        (Internal usage) The script of pushing packages to cachix.
      '';
    };
  };
}
