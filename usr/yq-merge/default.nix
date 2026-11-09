{ config, pkgs, lib, ... }: {
  options = {
    yq-merge = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            expr = lib.mkOption {
              default = null;
              type = lib.types.nullOr lib.types.anything;
              description = "Value to be transformed by `generator` into home.home.<xxx>.text";
            };
            generator = lib.mkOption {
              # Cannot set type to lib.types.functionTo lib.types.lines,
              # or the output will be merged.
              type = lib.types.anything;
            };
            preOnChange = lib.mkOption {
              default = "";
              type = lib.types.lines;
            };
            postOnChange = lib.mkOption {
              default = "";
              type = lib.types.lines;
            };
            yqExtraArgs = lib.mkOption {
              default = "";
              type = lib.types.str;
            };
          };
        }
      );
      default = {};
      description = ''
        Use yq to merge config file.
        The yq-merge."<name>" receive attr same as `home.file`.
      '';
      example = ./test.nix;
    };
  };
  config = {
    home.file = builtins.mapAttrs (old_target: value: rec {
      text = value.generator value.expr;
      target = "${dirOf old_target}/yq-merge.${baseNameOf old_target}";
      onChange = /*bash*/ ''
        ${value.preOnChange}
        if [[ -e ${old_target} ]]; then
          # Operator: `*d` means deeply merge and deeply merge array
          # See: https://mikefarah.gitbook.io/yq/operators/multiply-merge
          # Noted: If the element of array is string, the old array will be overwrite.
          run ${pkgs.yq-go}/bin/yq ea ${value.yqExtraArgs} -i 'select(fileIndex == 0) *d select(fileIndex == 1)' ${old_target} ${target}
        else
          cat ~/${target} > ~/${old_target}
        fi
        ${value.postOnChange}
      '';
    }) config.yq-merge;

    nixpkgs.overlays = [(final: prev: {
      yq-go = prev.yq-go.overrideAttrs (old: {
        patches = old.patches or [] ++ [(
          builtins.fetchurl {
            # fix: reset INI decoder state on init#2719
            url = "https://github.com/mikefarah/yq/pull/2719.patch";
            sha256 = "0skxii08vckxyg89f6dz66y1aspbyq25c99d9yzn8s2gdnksb5vc";
          }
        )];
      });
    })];
  };
}
