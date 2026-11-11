# TODO: is local/ a dummy name? What is the appropriate name?
{ pkgs }: # local args
{ lib, config, ... }: # global args
{
  imports = [
    ./win_align.nix
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

    package = lib.mkPackageOption pkgs "niri" {};
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

    config = lib.mkOption {
      type = lib.types.attrs;
      default = {};
    };
    finalConfig = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = config.lib.generators.toKDL {} config.config;
    };
  };
  config = {
    _module.args = { inherit pkgs; };
  };
}
