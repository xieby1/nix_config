let
  name = "nix_config";
  pkgs = import <nixpkgs> {};
  markcode = pkgs.callPackage (
    pkgs.fetchFromGitHub {
      owner = "xieby1";
      repo = "markcode";
      rev = "912e69e0131fe358ca27c65a7a5b0d33f2a3732c";
      hash = "sha256-stDWnTyYq1URYb6lx+hbe4lJnLPvHt8mBzLFEMZ34x0=";
    }
  ) {};
in pkgs.mkShell {
  inherit name;
  buildInputs = with pkgs; [
    mdbook
    markcode
  ];
}
