let
  name = "nix_config";
  pkgs = import <nixpkgs> {};
  markcode = pkgs.callPackage (
    pkgs.fetchFromGitHub {
      owner = "xieby1";
      repo = "markcode";
      rev = "aab7cdedae2a90fd1dea56a81fdf85689ef9b537";
      hash = "sha256-HCmtCnk3Q/Bng7QZzMm5C7nrKKNyz43yWLdv/CSuFyM=";
    }
  ) {};
in pkgs.mkShell {
  inherit name;
  buildInputs = with pkgs; [
    mdbook
    markcode
  ];
}
