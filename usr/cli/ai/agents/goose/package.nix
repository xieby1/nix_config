let
  pkgs = import <nixpkgs> {};
# in (pkgs.flake-compat {
#   src = pkgs.applyPatches {
#     name = "patched-goose-source";
#     src = pkgs.npinsed.ai.goose;
#     patches = [
#       # The upstream flake.nix is broken again! https://github.com/aaif-goose/goose/issues/9467
#       # It is funny that the flake.nix is broken again and again!
#     ];
#   };
# }).defaultNix.packages.${pkgs.stdenv.system}.default
  llm-agent-flake = pkgs.flake-compat {src = pkgs.npinsed.ai.llm-agents;};
in llm-agent-flake.defaultNix.packages."${builtins.currentSystem}".goose-cli.overrideAttrs (old: {
  patches = (old.patches or []) ++ [
    # Fix JW Codex
    ./responses-output-item-defaults.patch
  ];
})
