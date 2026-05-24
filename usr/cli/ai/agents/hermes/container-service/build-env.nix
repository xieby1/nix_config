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

    (import ../package.nix)
    (pkgs.writeShellScriptBin "start-hermes" ''
      # init
      if [[ ! -d ~/.hermes ]]; then
        hermes setup --non-interactive
      fi
      cp ${~/.hermes/config.yaml} ~/.hermes/config.yaml

      # Replace the shell wrapper with Hermes so Podman stop sends SIGTERM
      # directly to the gateway process instead of leaving it behind as a child.
      exec hermes gateway run
    '')
  ];
}
