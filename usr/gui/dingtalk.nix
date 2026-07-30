{ pkgs, ... }: {
  home.packages = [
    # TODO: cachix openssl (3min+ build time) and mesa (3min+ build time), see ~/.local/state/nix-output-monitor/build-reports.csv
    # As there is not dingtalk in nixpkgs, so we use dingtalk in nur.
    pkgs.nur.repos.yakkhini.dingtalk
  ];
}
