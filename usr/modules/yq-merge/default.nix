{ config, pkgs, lib, ... }: {
  options = {
    yq-merge = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            text = lib.mkOption {
              default = null;
              type = lib.types.nullOr lib.types.lines;
              description = "Pass to home.home.<xxx>.text";
            };
            preOnChange = lib.mkOption {
              default = "";
              type = lib.types.lines;
            };
            postOnChange = lib.mkOption {
              default = "";
              type = lib.types.lines;
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
      inherit (value) text;
      target = "${dirOf old_target}/yq-merge.${baseNameOf old_target}";
      onChange = /*bash*/ ''
        ${value.preOnChange}
        if [[ -e ${old_target} ]]; then
          # Operator: `*d` means deeply merge and deeply merge array
          # See: https://mikefarah.gitbook.io/yq/operators/multiply-merge
          # Noted: If the element of array is string, the old array will be overwrite.
          ${pkgs.yq-go}/bin/yq -i ea '. as $item ireduce ({}; . *d $item )' ${old_target} ${target}
        else
          cat ${target} > ${old_target}
        fi
        ${value.postOnChange}
      '';
    }) config.yq-merge;
  };
}
