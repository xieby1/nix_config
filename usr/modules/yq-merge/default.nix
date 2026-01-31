{ config, pkgs, lib, ... }: {
  options = {
    yq-merge = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = ''
        Use yq to merge config file.
        The yq-merge."<name>" receive attr same as `home.file`.
      '';
      example = ./test.nix;
    };
  };
  config = {
    home.file = builtins.mapAttrs (old_target: value: (value // rec {
      target = "${dirOf old_target}/yq-merge.${baseNameOf old_target}";
      onChange = ''
        if [[ -e ${old_target} ]]; then
          ${pkgs.yq-go}/bin/yq -i ea '. as $item ireduce ({}; . * $item )' ${old_target} ${target}
        else
          cat ${target} > ${old_target}
        fi
      '';
    })) config.yq-merge;
  };
}
