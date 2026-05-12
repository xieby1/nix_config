{
  rustPlatform,
  src,
  perl,
  pkg-config,
  openssl,
  onnxruntime,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  name = "vestige";
  inherit src;
  nativeBuildInputs = [
    perl
    pkg-config
  ];
  buildInputs = [
    openssl
  ];
  cargoLock = {
    lockFile = finalAttrs.src + /Cargo.lock;
  };
  env = {
    # ort need to donwload onnxruntime in build/main.rs, to prevent this:
    # refer to pkgs/by-name/hi/hieroglyphic/package.nix
    ORT_LIB_LOCATION = "${onnxruntime}/lib";
    ORT_PREFER_DYNAMIC_LINK = "1";
  };
  doCheck = false;
})
