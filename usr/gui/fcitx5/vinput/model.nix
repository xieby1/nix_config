{ pkgs }: let
  modelId = "model.sherpa-onnx.x-asr-960ms-streaming-zipformer-transducer-zh-en-punct-int8";
  archive = pkgs.fetchurl {
    url = "https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-x-asr-960ms-streaming-zipformer-transducer-zh-en-punct-int8-2026-06-05.tar.bz2";
    hash = "sha256-CpK3mL1oAcMzx86K6/W6dpv+fz81EWmaZ4N7IohChgM=";
  };
  registry = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/xifan2333/vinput-registry/5b39b073ac1b740aaba0bf104f47202bc9285da1/registry/models.json";
    hash = "sha256-LpCZ4fDCsAK3dT1HuW1CDgwaPsVTrdKGptROjPodyac=";
  };
in pkgs.runCommand "vinput-x-asr-960ms-int8-2026-06-05" {
  nativeBuildInputs = [ pkgs.gnutar pkgs.bzip2 pkgs.jq pkgs.sentencepiece ];
  passthru = { inherit modelId; };
} ''
  mkdir -p $out
  tar -xjf ${archive} --strip-components=1 -C $out
  # Vinput expects this vocabulary, but the archive only includes the SentencePiece model.
  spm_export_vocab --model=$out/bpe.model --output_format=vocab > $out/bpe.vocab
  jq -e --arg id '${modelId}' '
    .items[] | select(.id == $id) | .vinput_model
  ' ${registry} > $out/vinput-model.json
''
