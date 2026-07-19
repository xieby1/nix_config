{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

# mihomo-tui: lean MetaCubeXD-like API dashboard for an already-running core.
# clashtui: profile/template/config/service manager; useful, but much broader.
# Prefer mihomo-tui when the core is managed elsewhere and only TUI control is needed.
rustPlatform.buildRustPackage rec {
  pname = "mihomo-tui";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "potoo0";
    repo = "mihomo-tui";
    rev = "v${version}";
    hash = "sha256-LdNjSibwfR0aTjspwVTl91msZ+UwdQfM+C0d2Aytldc=";
  };

  cargoLock.lockFile = "${src}/Cargo.lock";

  # Upstream .cargo/config.toml sets this; Nix's cargo hook does not keep it.
  RUSTFLAGS = "--cfg tokio_unstable";

  VERGEN_GIT_DESCRIBE = "v${version}";
  VERGEN_BUILD_DATE = "2026-06-26";

  postPatch = ''
    echo 'fn main() {}' > build.rs
    substituteInPlace Cargo.toml \
      --replace-fail 'vergen-gitcl = { version = "10.0.0", features = ["build", "cargo"] }' ""
  '';

  meta = {
    description = "Terminal UI for Mihomo/Clash.Meta";
    homepage = "https://github.com/potoo0/mihomo-tui";
    license = lib.licenses.mit;
    mainProgram = "mihomo-tui";
    platforms = lib.platforms.linux;
  };
}
