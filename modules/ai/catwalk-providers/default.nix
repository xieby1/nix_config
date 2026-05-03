pkgs: let
  configs-dir = "${pkgs.npinsed.catwalk}/internal/providers/configs";
  name_jsons = builtins.attrNames (builtins.readDir configs-dir);
in pkgs.lib.listToAttrs (
  map (name_json: {
    name = pkgs.lib.removeSuffix ".json" name_json;
    value = import ./json-to-nix "${configs-dir}/${name_json}";
  }) name_jsons
)
