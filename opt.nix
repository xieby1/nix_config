{ config, pkgs, stdenv, lib, ... }:

{ options = {
  proxyPort = lib.mkOption {
    default = "8889";
    readOnly = true;
  };
  isCli = lib.mkOption {
    default = (builtins.getEnv "DISPLAY")=="";
    readOnly = true;
  };
  isGui = lib.mkOption {
    default = (builtins.getEnv "DISPLAY")!="";
    readOnly = true;
  };
};}