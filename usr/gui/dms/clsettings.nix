{ ... }: {
  yq-merge.".config/DankMaterialShell/clsettings.json" = {
    generator = builtins.toJSON;
    expr = {
      # default clipboard entries is 100
      maxHistory = 9999;
    };
  };
}
