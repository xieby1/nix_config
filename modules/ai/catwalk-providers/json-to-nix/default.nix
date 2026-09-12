json-file: let
  /*
    raw_nix = {
      ...
      models = [{
        id = "deepseek-flash";
        ...
      }{
        id = "deepseek-pro";
        ...
      }];
    };
  */
  raw_nix = builtins.fromJSON (builtins.readFile json-file);
/*
  output: {
    ...
    models = {
      deepseek-flash = {
        id = "deepseek-flash";
        ...
      };
      deepseek-pro = {
        id = "deepseek-pro";
        ...
      };
    };
  };
*/
in raw_nix // {
  models = builtins.listToAttrs (
    map (model: {
      name = model.id;
      value = model;
    }) raw_nix.models
  );
}
