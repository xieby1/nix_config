# TODO: is local/ a dummy name? What is the appropriate name?
{ pkgs, depkgs }: # local args
{ lib, config, ... }: # global args
{
  imports = [
    ./config
    ./win_align.nix
    ./focus-shrink
  ];
  options = {
    lib = lib.mkOption {
      type = lib.types.attrs;
      default = (import <home-manager/modules/lib/stdlib-extended.nix> lib).hm;
      description = ''
        Mimic home-manager's config.lib.
        How it works? See:
        - <home-manager>/modules/default.nix
        - <home-manager>/modules/modules.nix
      '';
    };

    package = lib.mkPackageOption depkgs "niri" {};
    patches = lib.mkOption {
      type = lib.types.listOf lib.types.anything;
      default = [];
    };
    finalPackage = lib.mkOption {
      type = lib.types.package;
      default = config.package.overrideAttrs (final: prev: {
        patches = prev.patches ++ config.patches;
      });
    };

    configKdl = lib.mkOption {
      # Copy from unstable home-manager's niri settings. Why type is necessary? Because, it define how merge is conducted.
      type =
        with lib.types;
        let
          valueType =
            nullOr (oneOf [
              bool
              int
              float
              str
              (attrsOf valueType)
              (listOf valueType)
            ])
            // {
              description = "KDL value";
            };
        in
        attrsOf valueType;
      default = {};
    };
    finalConfigKdlText = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = config.lib.generators.toKDL {} config.configKdl;
    };
  };
  config = {
    _module.args = { inherit pkgs depkgs; };

    patches = [
      # Fix dingtalk screen casting.
      # https://forum.archlinuxcn.org/t/topic/15526/3
      # [Support shm sharing #1791](https://github.com/YaLTeR/niri/pull/1791)
      (pkgs.fetchurl {
        name = "shm-sharing";
        url = "https://github.com/wrvsrx/niri/compare/tag_support-shm-sharing_4~19..tag_support-shm-sharing_4.patch";
        sha256 = "sha256-LLbzjrUmCXOCqboGKFc19Lw7hyE2tMHJdadWtltfn5U=";
      })
    ];
  };
}
