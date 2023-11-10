let
  name = "nix_config";
  pkgs = import <nixpkgs> {};
in pkgs.mkShell {
  inherit name;
  buildInputs = with pkgs; [
    mdbook
  ];
}
