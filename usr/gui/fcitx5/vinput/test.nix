let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;
  hm = import <home-manager/modules> {
    inherit pkgs;
    configuration = {
      imports = [ ../. ../../../modules/yq-merge ../../../cachix-push.nix ];
      home = { stateVersion = "25.11"; username = "dummy"; homeDirectory = "/dummy"; };
    };
  };
  cfg = hm.config;
  vinput = builtins.filter (p: lib.getName p == "fcitx5-vinput") cfg.i18n.inputMethod.fcitx5.addons;
  daemon = cfg.systemd.user.services.vinput-daemon or {};
in lib.runTests {
  test-addon = {
    expr = builtins.length vinput;
    expected = 1;
  };
  test-cli-and-gui-package = {
    expr = vinput != [] && builtins.elem (builtins.head vinput) cfg.home.packages;
    expected = true;
  };
  test-daemon = {
    expr = {
      type = daemon.Service.Type or null;
      bus = daemon.Service.BusName or null;
      after = daemon.Unit.After or [];
      wantedBy = daemon.Install.WantedBy or [];
    };
    expected = {
      type = "dbus";
      bus = "org.fcitx.Vinput";
      after = [ "pipewire.service" ];
      wantedBy = [ "default.target" ];
    };
  };
  test-daemon-executable = {
    expr = vinput != [] && (daemon.Service.ExecStart or []) == [ "${builtins.head vinput}/bin/vinput-daemon" ];
    expected = true;
  };
  test-unsupported-system = let
    unsupported = import <home-manager/modules> {
      pkgs = import <nixpkgs> { system = "riscv64-linux"; };
      configuration = {
        imports = [ ./. ../../../modules/yq-merge ../../../cachix-push.nix ];
        home = { stateVersion = "25.11"; username = "dummy"; homeDirectory = "/dummy"; };
      };
    };
  in {
    expr = {
      addons = unsupported.config.i18n.inputMethod.fcitx5.addons;
      daemon = unsupported.config.systemd.user.services ? vinput-daemon;
    };
    expected = { addons = []; daemon = false; };
  };
  test-managed-model = {
    expr = let
      model = cfg.xdg.dataFile."vinput/models/sherpa-onnx/x-asr-960ms-streaming-zipformer-transducer-zh-en-punct-int8".source or null;
    in model != null && (let
      manifest = builtins.fromJSON (builtins.readFile (model + "/vinput-model.json"));
    in manifest.backend == "sherpa-streaming"
      && manifest.runtime == "online"
      && manifest.language == "zh_en"
      && !(manifest.model ? sense_voice)
      && lib.all (file: builtins.pathExists (model + "/${file}")) [
        manifest.model.tokens manifest.model.bpe_vocab
        manifest.model.transducer.encoder manifest.model.transducer.decoder manifest.model.transducer.joiner
      ]);
    expected = true;
  };
  test-sensevoice-no-longer-managed = {
    expr = cfg.xdg.dataFile ? "vinput/models/sherpa-onnx/sense-voice-zh-en-ja-ko-yue-int8";
    expected = false;
  };
  test-selected-provider = {
    expr = cfg.yq-merge.".config/vinput/config.json".expr.asr.active_provider or null;
    expected = "sherpa-onnx";
  };
  test-model-selection-triggers-activation = {
    expr = lib.hasInfix "model.sherpa-onnx.x-asr-960ms-streaming-zipformer-transducer-zh-en-punct-int8"
      (cfg.home.file.".config/vinput/config.json".text or "");
    expected = true;
  };
  test-config-merge = {
    expr = if !(cfg.home.file ? ".config/vinput/config.json") then false else let
      file = cfg.home.file.".config/vinput/config.json";
      result = pkgs.runCommand "test-vinput-config-merge" { nativeBuildInputs = [ pkgs.jq ]; } ''
        export HOME=$TMPDIR/home
        mkdir -p "$HOME/.config/vinput"
        cd "$HOME"
        cp ${pkgs.writeText "vinput-settings.json" file.text} ${file.target}
        run() { "$@"; }
        apply() {
          ${file.onChange}
        }
        apply
        test -w .config/vinput/config.json
        jq -e '.asr.active_provider == "sherpa-onnx" and
          .asr.providers[0].model == "model.sherpa-onnx.x-asr-960ms-streaming-zipformer-transducer-zh-en-punct-int8" and
          .scenes.active_scene == "__raw__"' .config/vinput/config.json
        for providers in \
          '[{"id":"cloud","type":"command","env":{"TOKEN":"keep"}}]' \
          '[{"id":"cloud","type":"command","env":{"TOKEN":"keep"}},{"id":"sherpa-onnx","type":"local","timeout_ms":27000,"model":"model.sherpa-onnx.sense-voice-zh-en-ja-ko-yue-int8"}]'; do
          jq -n --argjson providers "$providers" \
            '{global:{capture_device:"keep-mic"},asr:{active_provider:"cloud",providers:$providers}}' \
            > .config/vinput/config.json
          apply
          apply
          jq -e '.global.capture_device == "keep-mic" and
            .asr.active_provider == "sherpa-onnx" and
            ([.asr.providers[] | select(.id == "cloud")][0].env.TOKEN == "keep") and
            ([.asr.providers[] | select(.id == "sherpa-onnx")] | length == 1) and
            ([.asr.providers[] | select(.id == "sherpa-onnx")][0].model ==
              "model.sherpa-onnx.x-asr-960ms-streaming-zipformer-transducer-zh-en-punct-int8")' .config/vinput/config.json
        done
        jq -e '[.asr.providers[] | select(.id == "sherpa-onnx")][0].timeout_ms == 27000' .config/vinput/config.json
        echo ok > $out
      '';
    in builtins.readFile result == "ok\n";
    expected = true;
  };
  test-existing-addons = {
    expr = lib.all (p: builtins.elem p cfg.i18n.inputMethod.fcitx5.addons) [
      pkgs.qt6Packages.fcitx5-chinese-addons pkgs.fcitx5-pinyin-zhwiki
      pkgs.fcitx5-mozc-ut pkgs.fcitx5-hangul
    ];
    expected = true;
  };
}
