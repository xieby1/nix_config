{ pkgs, ... }: {
  home.packages = [
    # As there is not dingtalk in nixpkgs, so we use dingtalk in nur.
    pkgs.nur.repos.yakkhini.dingtalk
  ];
  # Cachix long-build-time packages, see ~/.local/state/nix-output-monitor/build-reports.csv
  cachix_packages = (
    # openssl: 3min+ build time)
    builtins.filter
      (p: pkgs.lib.hasInfix "openssl" p)
      pkgs.nur.repos.yakkhini.dingtalk.buildInputs
  );
}
