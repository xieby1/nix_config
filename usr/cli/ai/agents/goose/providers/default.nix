{ pkgs, config, lib, ... }: let
  catwalkToCustomProvider = import ./catwalk-to-custom-provider.nix {inherit pkgs lib;};
in {
  imports = [
    (catwalkToCustomProvider config.ai.kimi)
    (catwalkToCustomProvider config.ai.minimax-china)
    (catwalkToCustomProvider config.ai.jw-codex)
  ];
}
