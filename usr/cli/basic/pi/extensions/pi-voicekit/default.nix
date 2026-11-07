{ pkgs, lib, ... }:
let
  model = import ./model.nix { inherit pkgs; };
  src = pkgs.applyPatches {
    name = "pi-voicekit-tts";
    src = pkgs.npinsed.ai.pi.pi-voicekit;
    patches = [ ./tts.patch ];
    nativeBuildInputs = [ pkgs.jq pkgs.bun ];
    postPatch = ''
      jq '
        del(.peerDependencies, .devDependencies, .optionalDependencies, .scripts, .overrides)
        | .dependencies = {"sherpa-onnx-node": "1.13.0"}
        | .overrides = {
            "sherpa-onnx-win-x64": "1.13.0",
            "sherpa-onnx-win-ia32": "1.13.0",
            "sherpa-onnx-linux-x64": "1.13.0",
            "sherpa-onnx-darwin-x64": "1.13.0",
            "sherpa-onnx-linux-arm64": "1.13.0",
            "sherpa-onnx-darwin-arm64": "1.13.0"
          }
      ' package.json > package.json.tmp
      mv package.json.tmp package.json
      cp ${./package-lock.json} package-lock.json
      bun scripts/build-workers.mjs
    '';
  };
  extension = pkgs.buildNpmPackage {
    pname = "pi-voicekit";
    version = "0.6.7";
    inherit src;
    npmDepsHash = "sha256-BktNiu3OcVP8U5gsdWRVEiZUbimQeTwg7/WLey/xsQw=";
    npmFlags = [ "--ignore-scripts" ];
    dontNpmBuild = true;
    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [ pkgs.stdenv.cc.cc.lib ];
  };
in lib.mkIf (builtins.elem pkgs.stdenv.hostPlatform.system [ "x86_64-linux" "aarch64-linux" ]) {
  home.file.".pi/agent/extensions/pi-voicekit".source = extension + "/lib/node_modules/pi-voicekit";
  home.file.".pi/models/tts/${model.modelId}".source = model;
  # Upstream uses paplay for Linux playback; the existing PipeWire server handles it.
  home.packages = [ pkgs.pulseaudio ];
  yq-merge.".pi/agent/settings.json" = {
    generator = builtins.toJSON;
    expr.voice = {
      enabled = false; # Fcitx5 vinput remains the dictation path.
      punctuationEnabled = false;
      previewEnabled = false;
      ttsEnabled = true;
      ttsAutoSpeak = false;
      ttsLocalModel = model.modelId;
      ttsLocalVoiceId = 0; # af_maple in the auditioned v1.1 model.
      ttsSpeed = 1.0;
      ttsOnboardingShown = true;
    };
  };
}
