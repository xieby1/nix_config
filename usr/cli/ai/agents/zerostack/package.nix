let
  pkgs = import <nixpkgs> {};
# The upstream source does not include flake.lock, so flake-compat cannot resolve the flake inputs required by outputs.
# Build the package directly with buildRustPackage for now.
# TODO: Switch back to flake-compat once upstream adds flake.lock.
in pkgs.rustPlatform.buildRustPackage {
  pname = "zerostack";
  version = pkgs.npinsed.ai.zerostack.version;
  src = pkgs.npinsed.ai.zerostack.outPath;
  cargoLock.lockFile = "${pkgs.npinsed.ai.zerostack.outPath}/Cargo.lock";

  nativeBuildInputs = with pkgs; [
    mold
    pkg-config
  ];

  buildInputs = with pkgs; [
    openssl
  ];

  preCheck = ''
    export XDG_DATA_HOME="$TMPDIR/xdg-data"
    mkdir -p "$XDG_DATA_HOME"
  '';

  buildFeatures = [ "acp" "memory" "multithread" ];
}
