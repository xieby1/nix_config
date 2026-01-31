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
        extension-settings = lib.mkOption {
          type = lib.types.mkOptionType {
            name = "attrsRecursiveUpdate";
            description = "attribute set";
            check = lib.isAttrs;
            merge = loc: lib.foldl' (res: def: lib.recursiveUpdate res def.value) { };
            emptyValue = {
              value = { };
            };
          };
          default = {};
          description = ''
            The extension-settings.json
          '';
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
            extension-settings = {
              ...
            };
          };
          profile1 = {...};
        };
      '';
    };
  };

  config = {
    yq-merge = (builtins.listToAttrs (lib.flatten (
      lib.mapAttrsToList (profile: per-profile-settings: (
        lib.mapAttrsToList (extensionId: per-extension-settings: {
          name = "${config.programs.firefox.configPath}/${profile}/browser-extension-data/${extensionId}/storage.js";
          value.text = builtins.toJSON per-extension-settings.storage;
        }) per-profile-settings.browser-extension-data
      )) config.firefox-extensions
    ))) // (
      lib.mapAttrs' (profile: per-profile-settings: {
        name = "${config.programs.firefox.configPath}/${profile}/extension-settings.json";
        value.text = builtins.toJSON ({
          version = 3;
        } // per-profile-settings.extension-settings);
      }) config.firefox-extensions
    );

    programs.firefox.profiles = lib.mapAttrs (profile: _: {
      settings = {
        "extensions.webextensions.ExtensionStorageIDB.enabled" = false;
      };
    }) config.firefox-extensions;
  };
}
