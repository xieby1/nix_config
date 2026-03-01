let
  pkgs = import <nixpkgs> {};
  dms-src = (pkgs.npinsed {input=./sources.json;}).DankMaterialShell;
  SPEC = pkgs.runCommand "SPEC" {} ''
    awk '/^var SPEC/,/^}/' ${dms-src}/quickshell/Common/settings/SettingsSpec.js > $out
  '';
  configVersion = pkgs.runCommand "configVersion" {} ''
    sed -n 's/.*readonly property int settingsConfigVersion: \([0-9]*\).*/\1/p' \
      ${dms-src}/quickshell/Common/SettingsData.qml | tr -d '\n' > $out
  '';
  gen-settings_js =  pkgs.writeTextFile {
    name = "gen-settings.js";
    text = /*js*/ ''
      const percentToUnit = null;
      ${builtins.readFile SPEC}
      var root = {};
      for (var k in SPEC) {
        if (SPEC[k].persist === false) continue;
        root[k] = SPEC[k].def;
      }
      root.configVersion = ${builtins.readFile configVersion};
      console.log(JSON.stringify(root, null, 2));
    '';
  };
in pkgs.runCommand "settings.json" {} ''
  ${pkgs.nodejs}/bin/node ${gen-settings_js} > $out
''
