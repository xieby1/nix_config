{ pkgs ? import <nixpkgs> {} }:
let
  package = import ./package.nix { inherit pkgs; };
  model = import ./model.nix { inherit pkgs; };
in pkgs.runCommand "pi-read-aloud-check" {
  nativeBuildInputs = [ pkgs.nodejs ];
  READ_ALOUD_PACKAGE = "${package}/lib/node_modules/pi-read-aloud";
  READ_ALOUD_MODEL = model;
  READ_ALOUD_MPV = pkgs.writeShellScript "mpv-null" ''
    exec ${pkgs.mpv-unwrapped}/bin/mpv --ao=null "$@"
  '';
} ''
  export HOME=$TMPDIR/home
  mkdir -p $HOME $out
  node --test ${./backend.test.mjs} > $out/backend.log 2>&1 || { cat $out/backend.log; exit 1; }
  cat $out/backend.log
  node --test ${./player.test.mjs} > $out/player.log 2>&1 || { cat $out/player.log; exit 1; }
  cat $out/player.log
''
