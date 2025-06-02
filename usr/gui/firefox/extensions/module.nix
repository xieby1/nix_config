{ config, pkgs, lib, ... }: {
  options = {
    firefox-extensions = lib.mkOption {
      #      per-profile
      type = lib.types.attrsOf (lib.types.submodule { options = {
        browser-extension-data = lib.mkOption {
          #      per-extension
          type = lib.types.attrsOf (lib.types.submodule { options = {
            storage = lib.mkOption {
              type = lib.types.attrs;
              default = {};
              description = ''
                Attrs that will be converted to json and merged to storage.js
              '';
            };
          };});
        };
      };});
      default = {};
      description = ''
        Attrs of firefox-extensions settings

        You may ask: why not using `programs.firefox.profiles.<name>.extensions.settings`?
        Because it do not support partially updating the settings.

        Example:

        firefox-extensions = {
          profile0 = {
            browser-extension-data = {
              darkreader = {
                storage = {
                  schemeVersion = 2;
                  syncSettings = false;
                  disabledFor = [
                    "http://127.0.0.1:7768"
                  ];
                };
              };
            };
          };
          profile1 = {...};
        };
      '';
    };
  };

  config = {
    home.file = builtins.listToAttrs (lib.flatten (
      lib.mapAttrsToList (profile: per-profile-settings: (
        lib.mapAttrsToList (extensionId: per-extension-settings: {
          name = "firefox-${profile}-${extensionId}";
          value = let
            relDir = "${config.programs.firefox.configPath}/${profile}/browser-extension-data/${extensionId}";
            absDir = "${config.home.homeDirectory}/${relDir}";
          in {
            target = "${relDir}/_storage_.js";
            text = builtins.toJSON per-extension-settings.storage;
            onChange = ''
              if [[ -e ${absDir}/storage.js ]]; then
                ${pkgs.yq-go}/bin/yq -i ea '. as $item ireduce ({}; . * $item )' ${absDir}/storage.js ${absDir}/_storage_.js
              else
                cat ${absDir}/_storage_.js > ${absDir}/storage.js
              fi
            '';
          };
        }) per-profile-settings.browser-extension-data
      )) config.firefox-extensions
    ));

    programs.firefox.profiles = lib.mapAttrs (profile: _: {
      settings = {
        "extensions.webextensions.ExtensionStorageIDB.enabled" = false;
      };
    }) config.firefox-extensions;
  };
}
