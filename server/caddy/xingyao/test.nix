# Evaluate real deployment modules with a disposable HOME/registry, never activate.
{ pkgs ? import <nixpkgs> { config = {}; overlays = []; } }:
let
  npinsFun = (import ../../../global-args { inherit (pkgs) lib; }).npinsFun;
  src = (npinsFun {input=../../xingyao/sources.json;}).xingyao;
  hm = import <home-manager/modules> {
    inherit pkgs;
    configuration = { lib, ... }: {
      imports = [
        ../../authelia
        (lib.modules.importApply ../../xingyao {inherit src;})
      ];
      options.my.server.caddyAuthelia.enable = lib.mkEnableOption "test proxy";
      config = {
        home.username = "test";
        home.homeDirectory = builtins.getEnv "HOME";
        home.stateVersion = "25.05";
        my.server.caddyAuthelia.enable = true;
      };
    };
  };
  cfg = hm.config;
  commandConfig = command: builtins.head (pkgs.lib.splitString " " (builtins.elemAt (pkgs.lib.splitString "--config " (builtins.head command)) 1));
in
assert builtins.all (a: a.assertion) cfg.assertions;
pkgs.writeText "xingyao-deployment-test.json" (builtins.toJSON {
  autheliaConfig = commandConfig cfg.systemd.user.services.authelia.Service.ExecStart;
  xingyao = cfg.systemd.user.services.xingyao-main;
  route = import ./caddy.nix;
})
