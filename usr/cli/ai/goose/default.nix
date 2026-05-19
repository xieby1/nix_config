# TODO: goose is deprecated, remove it in future.
{ pkgs, lib, ... }: let
  flake = pkgs.flake-compat { src = pkgs.npinsed.ai.goose; };
  flake-goose = flake.defaultNix.packages.${pkgs.stdenv.system}.default;
  flake-pkgs = import flake.defaultNix.inputs.nixpkgs {};
  # TODO: use latest nixpkgs and remove nixpkgs-goose-cli
  # https://github.com/NixOS/nixpkgs/issues/507256
  goose-unwrapped = flake-goose
  .overrideAttrs (old: {
    cargoDeps = flake-pkgs.rustPlatform.importCargoLock {
      lockFile = pkgs.npinsed.ai.goose + /Cargo.lock;
      outputHashes = {
        "cudaforge-0.1.6" = "sha256-w0e/mfx08BkphDEFEWxuyxyZu/gHiG0m6RHx+3BLzDY=";
        "opentelemetry-0.31.0" = "sha256-WmrsJUT+hhY9A0YrDMPCB+U23ZPNyX6eZlZ4VYlLk5Y=";
      };
    };
  });
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
