{
  lib,
  stdenv,
  fetchurl,
  dpkg,

  glfw3,
  file,
  mbedtls,
  freetype,
  dbus,
  zlib,
  glibc,
  bzip2,
  libpng,
  xorg,
  systemd,
  xz,
  zstd,
  lz4,
  libcap,
  libgcrypt,
  libgpg-error,
  libGL,
}:
let
  version = "1.20.0";
  rpath = lib.makeLibraryPath [
    glfw3
    file
    mbedtls
    freetype
    dbus
    zlib
    glibc
    bzip2
    libpng
    xorg.libX11
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXcursor
    xorg.libXi
    systemd
    xorg.libxcb
    xorg.libXext
    xorg.libXrender
    xorg.libXfixes
    xz
    zstd
    lz4
    libcap
    libgcrypt
    xorg.libXau
    xorg.libXdmcp
    libgpg-error
    libGL
  ] + ":${stdenv.cc.cc.lib}/lib64";
  src =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      fetchurl {
        urls = [
          "https://github.com/WerWolv/ImHex/releases/download/v1.20.0/imhex-1.20.0.deb"
        ];
        sha256 = "151aclqmpb5ij913mawznf6cmnyl32ij1y1z8wqmvl3gmhwx999l";
      }
    else
      throw "ImHex is not supported on ${stdenv.hostPlatform.system}";
in
stdenv.mkDerivation {
  pname = "imhex";
  inherit version;

  system = "x86_64-linux";

  inherit src;

  buildInputs = [ dpkg ];

  dontUnpack = true;
  installPhase = ''
    mkdir -p $out
    dpkg-deb -x $src $out
    mv $out/usr/* $out/
    rm -r $out/usr
  '';

  postFixup = ''
    for file in $(find $out -type f \( -perm /0111 -o -name \*.so\* \) ); do
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$file" || true
      patchelf --set-rpath ${rpath}:$out/lib/x86_64-linux-gnu $file || true
    done
  '';

  meta = with lib; {
    description = "ImHex";
    homepage = "https://github.com/WerWolv/ImHex";
    license = licenses.gpl2;
    maintainers = with maintainers; [ xieby1 ];
    platforms = [ "x86_64-linux" ];
  };
}
