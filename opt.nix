{ config, pkgs, stdenv, lib, ... }:

{ options = {
  proxyPort = lib.mkOption {
    default = "8889";
    readOnly = true;
  };
};}
