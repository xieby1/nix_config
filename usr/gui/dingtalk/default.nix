{ pkgs, ... }:
let
  # Build from our own nixpkgs so DingTalk, the wayland screen-share hook it
  # LD_PRELOADs, and the system binaries they spawn all share one glibc. A
  # pkgsu-built (glibc 2.44) hook aborts in those children with
  # `GLIBC_2.43' not found.
  #
  # Do NOT unset LD_PRELOAD in the hook's constructor: DingTalk's conference
  # child (`tblive`) is the process that does the X11 screen capture, and it only
  # starts the portal screencast (= the display picker) because of the preload.
  dingtalk = pkgs.callPackage (pkgs.nur.repo-sources.yakkhini.outPath + "/pkgs/dingtalk") {
    # Dropped from stable nixpkgs, but `lib/doctor` links it.
    # shortcut: unstable's gtkglext expr; re-check on pkgsu bumps.
    gtkglext = pkgs.callPackage (pkgs.pkgsu.path + "/pkgs/by-name/gt/gtkglext/package.nix") { };
  };
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
