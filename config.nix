# see pkgs/top-level/config.nix
{
  # disable install non-native packages, like install x86_64-linux packages on aarch64-linux
  allowUnsupportedSystem = false;
  allowUnfree = true;
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
    # pkgs unstable
    pkgsu = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/master.tar.gz") {};
  };
}
