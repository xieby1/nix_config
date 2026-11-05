{ pkgs }: let
  modelId = "model.sherpa-onnx.sense-voice-zh-en-ja-ko-yue-int8";
  archive = pkgs.fetchurl {
    url = "https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-int8-2025-09-09.tar.bz2";
    hash = "sha256-cwX3kFv893+gs5OIoxPz2jXGjZcWYaZUdbVvshYsjmM=";
  };
  registry = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/xifan2333/vinput-registry/5b39b073ac1b740aaba0bf104f47202bc9285da1/registry/models.json";
    hash = "sha256-LpCZ4fDCsAK3dT1HuW1CDgwaPsVTrdKGptROjPodyac=";
  };
in pkgs.runCommand "vinput-sensevoice-int8-2025-09-09" {
  nativeBuildInputs = [ pkgs.gnutar pkgs.bzip2 pkgs.jq ];
  passthru = { inherit modelId; };
} ''
  mkdir -p $out
  tar -xjf ${archive} --strip-components=1 -C $out
  # Upstream forces Chinese; auto also recognizes English without switching models.
  jq -e --arg id '${modelId}' '
    .items[] | select(.id == $id) | .vinput_model |
    .language = "auto" | .model.sense_voice.language = "auto"
  ' ${registry} > $out/vinput-model.json
''
