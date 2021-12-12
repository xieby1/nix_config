# add this file to /etc/nixos/configuration.nix: imports
{ config, pkgs, ... }:

{
  imports = [
    ./sys/cli.nix
    ./sys/gui.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  nix.extraOptions = ''
    experimental-features = nix-command
  '';

  services.syncthing = {
    enable = true;
    systemService = true;
    relay.enable = true;
    user = "xieby1";
    dataDir = "/home/xieby1";
    cert = "/home/xieby1/Vault/cert.${config.networking.hostName}.pem";
    key = "/home/xieby1/Vault/key.${config.networking.hostName}.pem";
    devices = {
      yoga14s = {
        id = "UKEYWMB-LY4XJCC-A5DP6ZS-VD7AJUO-XQMGSMW-WKH4OGN-IFIVLVL-7L6VSQJ";
        addresses = ["dynamic"];
      };
      y50_70 = {
        id = "OQIKUVW-NKZJAB7-GBQC3PL-4PVERNZ-7IDDY64-4X45ZGY-5ASR6C6-IHJMAQJ";
        addresses = ["dynamic"];
      };
      matepad = {
        id = "ST2THY7-CIZP6I4-VAS76ML-ERRJZG3-TO7A75L-XSMOIMK-7QJL25K-2RDBGQZ";
        addresses = ["dynamic"];
      };
      honor = {
        id = "7BIZFII-EDY7UJ2-4XCEIKZ-ORC23JL-5QYXCQL-2MSLSPI-MNFOKGL-6ASXSQK";
        addresses = ["dynamic"];
      };
    };
    folders = {
      Gist = {
        enable = true;
        id = "7noud-qsr3m";
        path = "/home/xieby1/Gist";
        ignorePerms = false;
        devices = [
          "yoga14s"
          "y50_70"
          "matepad"
          "honor"
        ];
        versioning = {
          type = "simple";
          params = {
            keep = "10";
            cleanoutDays = "1000";
          };
        };
      };
    };
  };

}
