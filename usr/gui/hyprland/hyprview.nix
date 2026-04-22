let
  pkgs = import <nixpkgs> {};
in pkgs.hyprlandPlugins.mkHyprlandPlugin (finalAttrs: {
  pluginName = "hyprview";
  version = "main";

  src = pkgs.fetchFromGitHub {
    owner = "yz778";
    repo = finalAttrs.pluginName;
    rev = "817c2543bbe6eff8d6ad40ebb4adf41c265762eb";
    hash = "sha256-nPSHF7kcVEwUIKTji9IiP1LPmkFxyaGakgAt9Ke1k9c=";
  };

  patchPhase = ''
    sed -i 's,g_pInputManager->unsetCursorImage,g_pPointerManager->resetCursorImage,g' src/hyprview.cpp
    # sed -i '/std::string HASH/,+6d' src/main.cpp
  '';
  buildPhase = ''
    make -C src all -j $NIX_BUILD_CORES
  '';
  installPhase = ''
    mkdir -p $out/lib
    cp build/hyprview.so $out/lib/lib${finalAttrs.pluginName}.so
  '';

  meta = {};
})
