{ pkgs ? import <nixpkgs> {} }:
let
  sources = import <npins> { input = ../sources.json; };
  pipkgs = import ../pkgs.nix { src = sources.nixpkgs; };
in pkgs.runCommand "pi-native-retry-check" {
  nativeBuildInputs = [ pipkgs.nodejs ];
  PI_ROOT = "${pipkgs.pi-coding-agent}/lib/node_modules/pi-monorepo";
} ''
  export HOME=$TMPDIR/home
  mkdir -p "$HOME" "$out"
  node --test ${./test.mjs} > "$out/retry.log" 2>&1 || { cat "$out/retry.log"; exit 1; }
  cat "$out/retry.log"
  # The CLI uses a separate bundle; both classifications must be compiled into it too.
  grep -rq 'basispoints_protocol_error' "$PI_ROOT/dist/bundle"
  grep -rq 'prompt_repetition_policy' "$PI_ROOT/dist/bundle"
''
