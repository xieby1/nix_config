let
  name = "nix_config";
  pkgs = import <nixpkgs> {};
  markcode = pkgs.callPackage (
    pkgs.fetchFromGitHub {
      owner = "xieby1";
      repo = "markcode";
      rev = "acd7ed3d56e4467881c1319ad0b1f239a9ad068c";
      hash = "sha256-HlQIbV9HwLRa+shmpXfaPzFKZL2XyjLaZ3Hk4CJjlwY=";
    }
  ) {};
in pkgs.mkShell {
  inherit name;
  buildInputs = with pkgs; [
    mdbook
    markcode
  ];
}
