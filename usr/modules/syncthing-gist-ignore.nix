{ config, lib, ... }: {
  # Manage ~/Gist/.stignore as a real file, not as a Home Manager symlink inside
  # the Syncthing folder. The generated source lives outside ~/Gist, and onChange
  # copies it into place only when the managed content changes. This lets multiple
  # modules contribute ignore patterns while avoiding synced /nix/store symlinks.
  # TODO: make it a more general module
  options.my.syncthing.Gist-stignore = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = ''
      Syncthing ignore patterns written to ~/Gist/.stignore.
      Patterns are interpreted relative to the ~/Gist Syncthing folder root.
    '';
  };

  config.home.file.".config/my-syncthing/Gist-stignore" = lib.mkIf (config.my.syncthing.Gist-stignore != [ ]) {
    text = lib.concatStringsSep "\n" config.my.syncthing.Gist-stignore;
    onChange = ''
      install -m 0644 ~/.config/my-syncthing/Gist-stignore ~/Gist/.stignore
    '';
  };
}
