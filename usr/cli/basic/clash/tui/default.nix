{ pkgs, ... }: let
  mihomo-tui = pkgs.callPackage ./package.nix {};
in {
  home.packages = [
    pkgs.mihomo
    mihomo-tui
    (pkgs.makeDesktopItem {
      name = "mihomo-tui";
      desktopName = "Mihomo TUI";
      keywords = ["mihomo" "clash" "tui"];
      exec = "kitty mihomo-tui";
      icon = pkgs.mihomo.src + /Meta.png;
    })
  ];
  cachix_packages = [
    mihomo-tui
  ];
  yq-merge.".config/mihomo-tui/config.yaml" = {
    generator = builtins.toJSON;
    expr = let
      clash-config-base = builtins.fromJSON (builtins.readFile ~/Gist/clash/base.json);
    in {
      mihomo-api = "http://${clash-config-base.external-controller}";
      mihomo-secret = clash-config-base.secret;
      log-file = "/tmp/mihomo-tui.log";
    };
  };
}
