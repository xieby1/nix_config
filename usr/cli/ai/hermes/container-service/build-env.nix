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
      fi
      # TODO: reuse the local hermes config
      hermes config set model.provider "minimax-cn"
      hermes config set model.base_url "https://api.minimaxi.com/anthropic";
      hermes config set model.default "MiniMax-M2.7"
      hermes config set web.backend "tavily"
      hermes config set web.search_backend "tavily"
      hermes config set web.extract_backend "tavily"
      hermes config set discord.require_mention false

      # Replace the shell wrapper with Hermes so Podman stop sends SIGTERM
      # directly to the gateway process instead of leaving it behind as a child.
      exec hermes gateway run
    '')
  ];
}
