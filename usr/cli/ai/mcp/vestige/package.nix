let
  pkgs = import <nixpkgs> {};
in pkgs.rustPlatform.buildRustPackage (finalAttrs: {
  name = "vestige";
  src = pkgs.npinsed.ai.vestige;
  nativeBuildInputs = [
    pkgs.perl
    pkgs.pkg-config
  ];
  buildInputs = [
    pkgs.openssl
  ];
  cargoLock = {
    lockFile = finalAttrs.src + /Cargo.lock;
  };
  env = {
    # ort need to donwload onnxruntime in build/main.rs, to prevent this:
    # refer to pkgs/by-name/hi/hieroglyphic/package.nix
    ORT_LIB_LOCATION = "${pkgs.pkgsu.onnxruntime}/lib";
    ORT_PREFER_DYNAMIC_LINK = "1";
  };
  doCheck = false;
})
