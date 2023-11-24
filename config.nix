#MC # config.nix
#MC
#MC When nixpkgs is initialized,
#MC it will read `~/.config/nixpkgs/config.nix` as the parameter of nixpkgs.config.
#MC If interested in initialization,
#MC go to read the source code of nixpkgs `<nixpkgs>/pkgs/top-level/impure.nix`.
#MC The possible parameters are listed in official nixpkgs manual
#MC [config Options Reference](https://nixos.org/manual/nixpkgs/stable/#sec-config-options-reference),
#MC or go to read the source code `<nixpkgs>/pkgs/top-level/config.nix`.
#MC
#MC My `config.nix` is annotated and listed as follows:
{
  #MC Disable installing non-native packages,
  #MC like preventing x86_64-linux packages installed on aarch64-linux.
  allowUnsupportedSystem = false;
  allowUnfree = true;
  packageOverrides = pkgs: {
    #MC Add nix user repository (NUR) to nixpkgs.
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
    #MC Add unstable nixpkgs to nixpkgs.
    #MC The unstable packages can be accessed like `pkgs.pkgsu.hello`.
    pkgsu = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/master.tar.gz") {};
  };
}
