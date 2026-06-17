{ pkgs, lib, ... }: let
  goose-unwrapped = import ./package.nix;
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
  imports = [
    ./providers
  ];
  home.packages = [ goose-wrapped ];
  cachix_packages = [ goose-unwrapped ];
  programs.zsh.initContent = lib.mkAfter ''
    eval "$(goose completion zsh)"
    eval "$(goose term init zsh)"
  '';
}
