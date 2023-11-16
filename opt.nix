{ config, pkgs, stdenv, lib, ... }:

{ options = {
  proxyPort = lib.mkOption {
    default = 8889;
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
  isNixOnDroid = lib.mkOption {
    default = config.home.username == "nix-on-droid";
    readOnly = true;
  };
  isWSL2 = lib.mkOption {
    default = (builtins.getEnv "WSL_DISTRO_NAME")!="";
    readOnly = true;
  };
};}
