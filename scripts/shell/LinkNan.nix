let
  name = "LinkNan";
  pkgs = import <nixpkgs> {};
in pkgs.mkShell {
  inherit name;

  buildInputs = let
    h_content = builtins.toFile "h_content" ''
      # ${pkgs.lib.toUpper "${name} usage tips"}
    '';
    _h_ = pkgs.writeShellScriptBin "h" ''
      ${pkgs.glow}/bin/glow ${h_content}
    '';
    mill_0_11_2 = (import (pkgs.fetchFromGitHub {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "4ab8a3de296914f3b631121e9ce3884f1d34e1e5";
      hash = "sha256-mQUik6XZea6ZcCkMpUieq1oxlEDE0vqTTRU9RStgtSQ=";
    }){}).mill;
  in [
    _h_
    mill_0_11_2
  ] ++ (with pkgs; [
    xmake
    espresso
    verilator

    # libs
    sqlite
    zlib
    zstd
  ]);

  shellHook = let
    circt_1_62_0 = (import (pkgs.fetchFromGitHub {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "771b079bb84ac2395f3a24a5663ac8d1495c98d3";
      sha256 = "0l1l9ms78xd41xg768pkb6xym200zpf4zjbv4kbqbj3z7rzvhpb7";
    }){}).circt;
  in ''
    h
    export CHISEL_FIRTOOL_PATH=${circt_1_62_0}/bin/
    export NOOP_HOME=$(realpath .)
  '';
}
