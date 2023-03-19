# see pkgs/top-level/config.nix
{
  allowUnsupportedSystem = true;
  allowUnfree = true;
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
    # pkgs unstable
    pkgsu = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/master.tar.gz") {};
  };
}
