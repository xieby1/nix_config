{ pkgs ? import <nixpkgs> {} }:
let
  package = import ./package.nix { inherit pkgs; };
  model = import ./model.nix { inherit pkgs; };
in pkgs.runCommand "pi-read-aloud-check" {
  nativeBuildInputs = [ pkgs.nodejs ];
  PI_ROOT = "${pkgs.pipkgs.pi-coding-agent}/lib/node_modules/pi-monorepo";
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
  node --test ${./text.test.mjs} ${./reader.test.mjs} > $out/controls.log 2>&1 || { cat $out/controls.log; exit 1; }
  cat $out/controls.log
  export READ_ALOUD_TEST_HOME=$HOME
  mkdir -p test-bin
  ln -s $READ_ALOUD_MPV test-bin/mpv
  export PATH=$PWD/test-bin:$PATH
  if ! node --test ${./index.test.mjs} > $out/index.log 2> $out/index-stderr.log; then
    cat $out/index.log $out/index-stderr.log
    exit 1
  fi
  cat $out/index.log
  test ! -s $out/index-stderr.log
  if grep -E 'Unknown token:|Skip unknown phonemes' $out/index.log; then exit 1; fi
  if ! node --test ${./rpc.test.mjs} > $out/rpc.log 2> $out/rpc-stderr.log; then
    cat $out/rpc.log $out/rpc-stderr.log
    exit 1
  fi
  cat $out/rpc.log
  test ! -s $out/rpc-stderr.log
''
