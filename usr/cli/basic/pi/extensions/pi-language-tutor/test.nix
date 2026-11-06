let
  pkgs = import <nixpkgs> {};
  module = import ./default.nix {
    inherit pkgs;
    lib = pkgs.lib;
    config.lib.file.mkOutOfStoreSymlink = path: path;
  };
  package = module.home.file.".pi/agent/extensions/pi-language-tutor".source;
in
assert !(module ? yq-merge);
assert module.home.file.".pi/agent/pi-language-tutor".source == ~/Gist/Data/pi/pi-language-tutor;
pkgs.runCommand "pi-language-tutor-storage-test" { nativeBuildInputs = [ pkgs.nodejs ]; } ''
  # Node refuses to strip TypeScript inside a node_modules directory.
  cp -rL ${package} package
  chmod -R u+w package
  for layout in fresh symlink; do
    export HOME="$TMPDIR/home-$layout"
    mkdir -p "$HOME"
    node ${./storage.test.mjs} "$PWD/package" "$layout"
  done
  touch $out
''
