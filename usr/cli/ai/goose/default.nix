# TODO: goose is deprecated, remove it in future.
{ pkgs, lib, ... }: let
  # TODO: use latest nixpkgs and remove nixpkgs-goose-cli
  # https://github.com/NixOS/nixpkgs/issues/507256
  goose-unwrapped = (import pkgs.npinsed.ai.nixpkgs-goose-cli {}).goose-cli;
  goose-wrapped = pkgs.runCommand "goose-wrapped" {
    nativeBuildInputs = [pkgs.makeWrapper];
    passthru.unwrapped = goose-unwrapped;
  } ''
    mkdir -p $out
    ${pkgs.xorg.lndir}/bin/lndir -silent ${goose-unwrapped} $out
    for bin in $out/bin/*; do
      wrapProgram $bin \
        --set GOOSE_DISABLE_KEYRING 1
    done
  '';
in {
  home.packages = [ goose-wrapped ];
  programs.zsh.initContent = lib.mkAfter ''
    eval "$(goose completion zsh)"
  '';
}
