{
  allowUnsupportedSystem = true;
  allowUnfree = true;
  packageOverrides = pkgs: {
    nur = import (pkgs.fetchFromGitHub {
      # https://github.com//NUR/commit/
      owner = "nix-community";
      repo = "NUR";
      rev = "d67c890fc1096b9c8706c1c46f8e3fec06add355";
      sha256 = "1afx34940l6yf4n7dgljdyk0r8gbn7p26kkk9n9wqq4m8ng1bmh2";
    }) {
      inherit pkgs;
    };
  };
}
