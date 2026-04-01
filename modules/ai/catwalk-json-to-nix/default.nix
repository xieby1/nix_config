json-file: let
  /*
    raw_nix = {
      ...
      models = [{
        id = "deepseek-chat";
        ...
      }{
        id = "deepseek-reasoner";
        ...
      }];
    };
  */
  raw_nix = builtins.fromJSON (builtins.readFile json-file);
/*
  output: {
    ...
    models = {
      deepseek-chat = {
        id = "deepseek-chat";
        ...
      };
      deepseek-reasoner = {
        id = "deepseek-reasoner";
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
