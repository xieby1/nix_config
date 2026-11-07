{ pkgs ? import <nixpkgs> {} }:
let
  cfg = (import ./default.nix { inherit pkgs; inherit (pkgs) lib; }).content;
  extension = cfg.home.file.".pi/agent/extensions/pi-voicekit".source;
  model = cfg.home.file.".pi/models/tts/kokoro-multi-lang-v1_1".source;
  settings = pkgs.writeText "voicekit-test-settings.json"
    (builtins.toJSON cfg.yq-merge.".pi/agent/settings.json".expr);
  pi = "${pkgs.pipkgs.pi-coding-agent}/lib/node_modules/pi-monorepo";
in pkgs.runCommand "pi-voicekit-check" {
  nativeBuildInputs = [ pkgs.nodejs pkgs.bun ];
  PI_ROOT = pi;
  VOICEKIT_DIR = extension;
  VOICEKIT_MODEL = model;
  VOICEKIT_SETTINGS = settings;
} ''
  mkdir -p work/node_modules/@earendil-works
  cp -R ${extension}/extensions work/
  cp -R ${pkgs.npinsed.ai.pi.pi-voicekit}/tests work/
  chmod -R u+w work
  cp ${./integration.test.ts} work/tests/nix-integration.test.ts
  ln -s ${pi} work/node_modules/@earendil-works/pi-coding-agent
  ln -s ${pi}/node_modules/@earendil-works/pi-tui work/node_modules/@earendil-works/pi-tui
  cd work
  for name in nix-integration tts-local-models tts-text-filter tts-playback speak; do
    export HOME=$(mktemp -d)
    export VOICEKIT_TEST_HOME=$HOME
    bun test "tests/$name.test.ts"
    rm -rf "$HOME"
  done
  export HOME=$(mktemp -d)
  export VOICEKIT_TEST_HOME=$HOME
  node ${./smoke.mjs} > native-result.json 2> native-stderr.log
  mkdir -p $out
  cp native-result.json native-stderr.log $out/
''
