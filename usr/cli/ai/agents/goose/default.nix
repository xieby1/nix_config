{ pkgs, config, lib, ... }: let
  goose-unwrapped = import ./package.nix;
  catwalkToCustomProvider = import ./catwalk-to-custom-provider.nix {inherit pkgs lib goose-unwrapped;};
in {
  imports = [
    (catwalkToCustomProvider config.ai.kimi)
    (catwalkToCustomProvider config.ai.minimax-china)
    (catwalkToCustomProvider config.ai.jw-codex)
  ];
  # If zsh alias goose=goose-jw-codex, then the completion does not works for this aliased goose, I do not know why.
  # So I create a simple executable wrapper.
  home.packages = [(pkgs.writeShellScriptBin "goose" "goose-jw-codex $@")];
  cachix_packages = [ goose-unwrapped ];
  programs.zsh.initContent = lib.mkAfter ''
    eval "$(goose completion zsh)"
    eval "$(goose term init zsh)"
  '';
  home.file.".agents/skills".source = config.lib.file.mkOutOfStoreSymlink ~/Gist/Data/hermes/skills;
}
