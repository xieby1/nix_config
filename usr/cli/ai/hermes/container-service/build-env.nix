let
  pkgs = import <nixpkgs> {};
in pkgs.buildEnv {
  name = "hermes-container-root";
  paths = [
    pkgs.bashInteractive
    pkgs.cacert
    pkgs.coreutils
    pkgs.file
    pkgs.git
    pkgs.gnutar
    pkgs.nix
    pkgs.wget

    (pkgs.flake-compat {src=pkgs.npinsed.ai.llm-agents;})
      .defaultNix.packages.${pkgs.stdenv.system}.hermes-agent
    (pkgs.writeShellScriptBin "start-hermes" ''
      # init
      if [[ ! -d ~/.hermes ]]; then
        hermes setup --non-interactive
        hermes config set model.provider "kimi-coding"
        hermes config set model.base_url "https://api.kimi.com/coding";
        hermes config set model.default "kimi-for-coding"
      fi
      hermes gateway run
    '')
  ];
}
