{ pkgs }:
let
  modelId = "kokoro-multi-lang-v1_1";
  archive = pkgs.fetchurl {
    url = "https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/${modelId}.tar.bz2";
    hash = "sha256-t44axCuFLoOczqr76I9mgGv1hgmS0de5o/KtEZhCeu0=";
  };
in pkgs.runCommand modelId {
  nativeBuildInputs = [ pkgs.gnutar pkgs.bzip2 ];
  passthru = { inherit modelId; };
} ''
  mkdir -p $out
  tar -xjf ${archive} --strip-components=1 -C $out
  for file in model.onnx voices.bin tokens.txt lexicon-us-en.txt lexicon-zh.txt number-zh.fst date-zh.fst phone-zh.fst; do
    test -s "$out/$file"
  done
  test -d $out/espeak-ng-data
''
