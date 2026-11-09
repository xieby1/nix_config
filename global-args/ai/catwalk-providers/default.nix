{ catwalk, lib }: let
  configs-dir = "${catwalk}/internal/providers/configs";
  name_jsons = builtins.attrNames (builtins.readDir configs-dir);
in lib.listToAttrs (
  map (name_json: {
    name = lib.removeSuffix ".json" name_json;
    value = import ./json-to-nix "${configs-dir}/${name_json}";
  }) name_jsons
)
