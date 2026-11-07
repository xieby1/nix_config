let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;
  cfg = (lib.evalModules {
    specialArgs = { inherit pkgs; };
    modules = [
      {
        options.home.file = lib.mkOption { type = lib.types.attrsOf lib.types.anything; default = {}; };
        options.home.packages = lib.mkOption { type = lib.types.listOf lib.types.package; default = []; };
        options.yq-merge = lib.mkOption { type = lib.types.attrsOf lib.types.anything; default = {}; };
      }
      ./default.nix
    ];
  }).config;
  voice = cfg.yq-merge.".pi/agent/settings.json".expr.voice or {};
in lib.runTests {
  test-extension-installed = {
    expr = cfg.home.file ? ".pi/agent/extensions/pi-voicekit";
    expected = true;
  };
  test-model-installed = {
    expr = cfg.home.file ? ".pi/models/tts/kokoro-multi-lang-v1_1";
    expected = true;
  };
  test-tts-enabled = { expr = voice.ttsEnabled or null; expected = true; };
  test-vinput-remains-dictation = { expr = voice.enabled or null; expected = false; };
  test-no-automatic-narration = { expr = voice.ttsAutoSpeak or null; expected = false; };
  test-auditioned-model = { expr = voice.ttsLocalModel or null; expected = "kokoro-multi-lang-v1_1"; };
  test-auditioned-voice = { expr = voice.ttsLocalVoiceId or null; expected = 0; };
  test-auditioned-speed = { expr = voice.ttsSpeed or null; expected = 1.0; };
  test-no-punctuation-download = { expr = voice.punctuationEnabled or null; expected = false; };
  test-no-preview-download = { expr = voice.previewEnabled or null; expected = false; };
}
