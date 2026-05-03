{ pkgs, ... }: {
  home.packages = [(
    pkgs.gnomeExtensions.auto-accent-colour.overrideAttrs (old: {
      postPatch = ''
        substituteInPlace extension.js --replace "gjs" "${pkgs.gjs}/bin/gjs"
      '';
    })
  )];
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "auto-accent-colour@Wartybix"
      ];
    };
    "org/gnome/shell/extensions/auto-accent-colour" = {
      hide-indicator = true;
    };
  };
}
