# TODO: is local/ a dummy name? What is the appropriate name?
{ pkgs, depkgs }: # local args
{ lib, config, ... }: # global args
{
  imports = [
    ./config
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
      type = lib.types.attrs;
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
  };
}
