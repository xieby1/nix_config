{ pkgs, config, lib, ... }: {
  options = {
    config_fcitx5 = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = {};
      description = ''
        The fcitx5 config files in ~/.config/fcitx5/
      '';
    };
  };
  config = {
    xdg.configFile = lib.mapAttrs' (path: source: lib.nameValuePair
      "config_fcitx5_${baseNameOf path}"
      (let
        relDir = "fcitx5";
        absDir = "${config.xdg.configHome}/${relDir}";
        _path_ = "${dirOf path}/_${baseNameOf path}_";
      in {
        target = "${relDir}/${_path_}";
        inherit source;
        onChange = ''
          if [[ -e ${absDir}/${path} ]]; then
            ${pkgs.crudini}/bin/crudini --merge ${absDir}/${path} < ${absDir}/${_path_}
          else
            cat ${absDir}/${_path_} > ${absDir}/${path}
          fi
        '';
      })
    ) config.config_fcitx5;
  };
}
