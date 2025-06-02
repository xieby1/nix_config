{ config, pkgs, lib, ... }: {
  options = let
    extension-settings = {
      options = {
        storage = lib.mkOption {
          type = lib.types.attrs;
          default = {};
          description = ''
            Attrs that will be converted to json and merged to storage.js
          '';
        };
      };
    };
  in {
    firefox-extensions = lib.mkOption {
      #      per-profile        per-extension
      type = lib.types.attrsOf (lib.types.attrsOf (lib.types.submodule extension-settings));
      default = {};
      description = ''
        Attrs of firefox-extensions settings

        You may ask: why not using `programs.firefox.profiles.<name>.extensions.settings`?
        Because it do not support partially updating the settings.

        Example:

        firefox-extensions = {
          profile0 = {
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
          profile1 = {...};
        };
      '';
    };
  };

  config = let
    /*
      mapAttrsAttrsToList (name1: name2: value2: <func-body>) <attrs>
      <func-body> must return a name-value pair.
      Example:
         attrs = { a={x=0;y=1;}; b={x=2;y=3;}; };
         mapAttrsAttrs (n1: n2: v2: {name=n1+n2; value=v2;}) attrs
      => {ax=0; ay=1; bx=2; by=3;}
    */
    mapAttrsAttrs = f: attrs: builtins.listToAttrs (lib.flatten (
      lib.mapAttrsToList (
        n1: v1: (lib.mapAttrsToList (n2: v2: f n1 n2 v2)) v1
      ) attrs
    ));
  in {
    home.file = mapAttrsAttrs (profile: extensionId: settings: {
      name = "firefox-${profile}-${extensionId}";
      value = {
        target = ".mozilla/firefox/${profile}/browser-extension-data/addon@darkreader.org/_storage_.js";
        text = builtins.toJSON settings.storage;
        onChange = ''
          ${pkgs.yq-go}/bin/yq -i ea '. as $item ireduce ({}; . * $item )' \
            ${config.home.homeDirectory}/${config.programs.firefox.configPath}/${profile}/browser-extension-data/${extensionId}/storage.js \
            ${config.home.homeDirectory}/${config.programs.firefox.configPath}/${profile}/browser-extension-data/${extensionId}/_storage_.js
        '';
      };
    }) config.firefox-extensions;

    programs.firefox.profiles = mapAttrsAttrs (profile: extension: settings: {
      name = "${profile}";
      value = {
        settings = {
          "extensions.webextensions.ExtensionStorageIDB.enabled" = false;
        };
      };
    }) config.firefox-extensions;
  };
}
