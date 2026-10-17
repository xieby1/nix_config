{ pkgs, ... }:
let
  dingtalk' = pkgs.nur.repos.yakkhini.dingtalk;
  hook0 = dingtalk'.passthru.dingtalk-wayland-screenshare;
  # DingTalk's wrapper sets LD_PRELOAD (this hook) and LD_LIBRARY_PATH to pkgsu
  # (unstable, glibc 2.44) libs. DingTalk spawns system binaries (e.g.
  # `sh -c 'cat /etc/os-release'`) that use the system glibc 2.42, so preloading
  # this pkgsu-built hook into them fails (`GLIBC_2.43' not found). Clear
  # LD_PRELOAD in the hook's constructor, before DingTalk can spawn children, so
  # only the already-loaded main process keeps the hook. LD_LIBRARY_PATH is left
  # alone: the hook dlopens libXdamage/opencv by bare name and relies on it.
  hook = hook0.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      printf '%s\n' \
        '#include <cstdlib>' \
        '__attribute__((constructor)) static void __dt_strip_leaky_env() {' \
        '  unsetenv("LD_PRELOAD");' \
        '}' >> hook.cpp
    '';
  });
  dingtalk = dingtalk'.overrideAttrs (old: {
    installPhase = builtins.replaceStrings [ hook0.outPath ] [ "${hook}" ] old.installPhase;
  });
in
{
  home.packages = [
    # As there is not dingtalk in nixpkgs, so we use dingtalk in nur.
    dingtalk
  ];
  # Cachix long-build-time packages, see ~/.local/state/nix-output-monitor/build-reports.csv
  cachix_packages = (
    # openssl: 3min+ build time)
    builtins.filter
      (p: pkgs.lib.hasInfix "openssl" p)
      dingtalk.buildInputs
  );
}
