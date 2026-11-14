{ pkgs, ... }:
let
  # As there is not dingtalk in nixpkgs, so we use dingtalk in nur.
  dingtalk = pkgs.nur.repos.yakkhini.dingtalk;
in {
  home.packages = [ dingtalk ];
  # Cachix long-build-time packages, see ~/.local/state/nix-output-monitor/build-reports.csv
  # openssl: 3min+ build time)
  cachix_packages = builtins.filter (p: pkgs.lib.hasInfix "openssl" p) dingtalk.buildInputs;
}
