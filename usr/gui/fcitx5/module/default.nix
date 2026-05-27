{ config, lib, ... }: {
  options = {
    my.config-fcitx5 = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = {};
      description = ''
        The fcitx5 config files in ~/.config/fcitx5/
        The implementation is based on yq-merge module.
      '';
    };
  };
  config = {
    yq-merge = lib.mapAttrs (path: attrs: {
      generator = lib.generators.toINIWithGlobalSection {};
      yqExtraArgs = "-o ini -p ini";
      # `yq`'s `--properties-separator '='` only works for properties files, not for INI.
      # So we manually strip spaces around `=`.
      postOnChange = ''sed -i 's/\s\+=\s\+/=/' ${path}'';
    } // attrs) config.my.config-fcitx5;
  };
}
