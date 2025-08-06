{ pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/1dab772dd4a68a7bba5d9460685547ff8e17d899.tar.gz";
    sha256 = "18qwmspcsmi0ryhcg66p9i42qwismm7l0706m39zw5ziq6n11fc9";
  }) {}
, CONFIG ? "XSNoCTopConfig" # "DefaultConfig"
, EMU_THREADS ? "4"
, NUM_CORES ? "1"
, EMU_TRACE ? "fst" # "fst" or "vcd"
, genRTL ? false
}:
let
  xs-src = let
    rev = "ff4344e4e52d4e58ba1570da9ace0dafaca74de0";
    outputHash = "sha256-N4gh0VH54vGPbq7elUfwmzr3rQdC6mfRDdRxEVgpRcE=";
  in pkgs.stdenv.mkDerivation {
    name = "OpenXiangShan";
    nativeBuildInputs = [
      pkgs.git
      pkgs.cacert
    ];
    impureEnvVars = pkgs.lib.fetchers.proxyImpureEnvVars ++ [
      "GIT_PROXY_COMMAND"
      "NIX_GIT_SSL_CAINFO"
      "SOCKS_SERVER"
    ];
    deterministic_git = let
      nix-prefetch-git = "${pkgs.path}/pkgs/build-support/fetchgit/nix-prefetch-git";
    in pkgs.runCommand "deterministic-git" {} ''
      sed -n '/clean_git(){/,/^}/p'               ${nix-prefetch-git}  > $out
      sed -n '/make_deterministic_repo(){/,/^}/p' ${nix-prefetch-git} >> $out
    '';
    builder = builtins.toFile "builder.sh" ''
      . $stdenv/setup
      mkdir -p $out
      git clone https://github.com/OpenXiangShan/XiangShan $out
      git -C $out checkout ${rev}
      make -C $out init
      source $deterministic_git
      find $out -name .git | while read -r gitdir; do
        make_deterministic_repo "$(readlink -f "$(dirname "$gitdir")")" || true
      done
    '';
    outputHashMode = "recursive";
    inherit rev outputHash;
  };

  # mill deps refer to https://github.com/com-lihaoyi/mill/discussions/1170
  millDeps = pkgs.stdenv.mkDerivation {
    name = "xs-mill-cache";
    src = xs-src;
    nativeBuildInputs = [ pkgs.mill ];
    # [COURSIER_CACHE with relative path cause artifacts download into process sandbox folder](https://github.com/com-lihaoyi/mill/issues/3946)
    # Thus, COURSIER_CACHE uses absolute path like below
    buildPhase = ''
      export COURSIER_CACHE=$PWD/.cache/coursier
      mill __.prepareOffline
    '';
    installPhase = ''
      cp -r $COURSIER_CACHE $out
    '';
    outputHashMode = "recursive";
    outputHash = "sha256-9qL+2W2KSHIV4KxhfY9F+2j1xP8NCW7mC/CO2EWbYh8=";
  };
in pkgs.stdenv.mkDerivation {
  name = "xs";
  src = xs-src;
  nativeBuildInputs = [
    pkgs.makeWrapper
    pkgs.mill
    pkgs.time
    pkgs.espresso
    pkgs.verilator
    pkgs.sqlite
    pkgs.zlib
    pkgs.zstd
    pkgs.python3
  ];
  COURSIER_CACHE = millDeps;

  postPatch = ''
    patchShebangs scripts/
  ''
  # The .git/ folder format is not stable, thus hard to achieve deterministic.
  # For more information about .git/ and deterministic see the `leaveDotGit` option in
  # [nixpkgs manual: fetchgit](https://nixos.org/manual/nixpkgs/stable/#fetchgit).
  # 1. Clean vcs.version scala lib, which needs the .git/ folder.
  + ''
    find -name build.sc -exec sed -i '/vcs.version/d' {} \;
    sed -i '/def publishVersion/,/^  )$/c\  def publishVersion() = "deterministic-version"' build.sc
    find -name build.sc -exec sed -i 's/def publishVersion =.*vcs.version.*/def publishVersion = "miao"/' {} \;
  ''
  # 2. Clean git related operations in build.sc
  + ''
    sed -i '/def gitStatus:/,/^  }/c\  def gitStatus() = "SHA=${xs-src.rev}\\ndirty=0"' build.sc
    sed -i 's/"git", "ls-files"/"ls", "-1"/' build.sc
    sed -i 's/os.proc("git", "submodule", "status").call().out.text()/""/' build.sc
  ''
  # 3. Clean git in Makefile
  + ''
    sed -i '/@git log/,/rm .__head__/d' Makefile
  '';

  buildPhase = let
    # current version of Chisel (6.6.0) was published against firtool version 1.62.1
    circt_1_62_0 = (import (pkgs.fetchFromGitHub {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "771b079bb84ac2395f3a24a5663ac8d1495c98d3";
      sha256 = "0l1l9ms78xd41xg768pkb6xym200zpf4zjbv4kbqbj3z7rzvhpb7";
    }){}).circt;
  in ''
    export CHISEL_FIRTOOL_PATH=${circt_1_62_0}/bin/
    export NOOP_HOME=$(realpath .)
    make emu CONFIG=${CONFIG} EMU_THREADS=${EMU_THREADS} NUM_CORES=${NUM_CORES} EMU_TRACE=${EMU_TRACE} -j $NIX_BUILD_CORES
  '';

  outputs = ["out"] ++ pkgs.lib.optional genRTL "rtl";
  installPhase = ''
    mkdir -p $out/bin
    cp build/emu $out/bin/
    wrapProgram $out/bin/emu --prefix PATH : ${pkgs.lib.makeBinPath [pkgs.spike]}
  '' + pkgs.lib.optionalString genRTL ''
    mkdir -p $rtl
    cp -r build/rtl/* $rtl/
  '';
}
