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
        hermes config set model.provider "minimax-cn"
        hermes config set model.base_url "https://api.minimaxi.com/anthropic";
        hermes config set model.default "MiniMax-M2.7"
      fi

      # Replace the shell wrapper with Hermes so Podman stop sends SIGTERM
      # directly to the gateway process instead of leaving it behind as a child.
      exec hermes gateway run
    '')
  ];
}
