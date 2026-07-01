{ config, pkgs, ... }: {
  imports = [
    ./pi
    ./hermes
    ./goose
    ./zerostack
  ];
}
