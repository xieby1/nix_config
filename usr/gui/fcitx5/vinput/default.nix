{ pkgs, lib, ai, ... }: let
  system = pkgs.stdenv.hostPlatform.system;
  model = import ./model.nix { inherit pkgs; };
  modelName = lib.removePrefix "model.sherpa-onnx." model.modelId;
  vinput = (pkgs.flake-compat {
    src = (import <npins> {input=./sources.json;}).fcitx5-vinput;
  }).defaultNix.packages.${system}.default;
in lib.mkIf (builtins.elem system [ "x86_64-linux" "aarch64-linux" ]) {
  home.packages = [ vinput ];
  cachix_packages = [ vinput ];
  i18n.inputMethod.fcitx5.addons = [ vinput ];

  xdg.dataFile."vinput/models/sherpa-onnx/${modelName}".source = model;
  yq-merge.".config/vinput/config.json" = {
    generator = builtins.toJSON;
    expr.asr = {
      active_provider = "sherpa-onnx";
      providers = [{ id = "sherpa-onnx"; type = "local"; model = model.modelId; }];
    };
    expr.llm.providers = [{
      id = ai.default_small.provider.id;
      base_url = ai.default_small.provider.api_endpoint;
      api_key = ai.default_small.provider.api_key;
    }];
    expr.scenes = {
      active_scene = "correct";
      definitions = [{
        id = "correct";
        label = "语音纠错";
        prompt = "你是语音识别后处理器。纠正同音字、错别字、标点和明显识别错误，严格保留原意和输入语言，不改变语气，不回答问题，不补充内容。";
        provider_id = ai.default_small.provider.id;
        model = ai.default_small.model.id;
        # Recent Vinput history records sent to the LLM; 0 avoids extra latency and data sharing.
        context_lines = 0;
        count = 1;
        timeout_ms = 8000;
      }];
    };
    yqExtraArgs = "-p json -o json";
    preOnChange = ''
      if [[ ! -e .config/vinput/config.json ]]; then
        run ${pkgs.coreutils}/bin/install -Dm600 \
          ${vinput}/share/fcitx5-vinput/default-config.json .config/vinput/config.json
      fi
      # yq-merge matches arrays by index; move managed entries first without losing others.
      run ${pkgs.yq-go}/bin/yq -p json -o json -i '
        (.asr.providers // []) as $providers |
        .asr.providers = (
          ([$providers[] | select(.id == "sherpa-onnx")] +
            [{"id": "sherpa-onnx"}] | unique_by(.id)) +
          [$providers[] | select(.id != "sherpa-onnx")]
        ) |
        (.llm.providers // []) as $llmProviders |
        .llm.providers = (
          ([$llmProviders[] | select(.id == "${ai.default_small.provider.id}")] +
            [{"id": "${ai.default_small.provider.id}"}] | unique_by(.id)) +
          [$llmProviders[] | select(.id != "${ai.default_small.provider.id}")]
        ) |
        (.scenes.definitions // []) as $scenes |
        .scenes.definitions = (
          ([$scenes[] | select(.id == "correct")] +
            [{"id": "correct"}] | unique_by(.id)) +
          [$scenes[] | select(.id != "correct")]
        )
      ' .config/vinput/config.json
    '';
  };

  systemd.user.services.vinput-daemon = {
    Unit = {
      Description = "Vinput Voice Input Daemon";
      After = [ "pipewire.service" ];
      X-Restart-Triggers = [ "${model}" ];
    };
    Service = {
      Type = "dbus";
      BusName = "org.fcitx.Vinput";
      ExecStart = "${vinput}/bin/vinput-daemon";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
