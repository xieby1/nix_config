{ config, pkgs, ... }:

{
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
      qemu = {
        id = "2SHHM4X-Q3WKRXD-5TUFXSE-BFXJ2M6-75XSW7V-J37IGTN-C6UM2HS-TK2V6QT";
        addresses = ["dynamic"];
      };
    };
    folders = {
      Vault = {
        enable = true;
        id = "tcaa6-xk2jp";
        path = "/home/xieby1/Vault";
        ignorePerms = false;
        devices = [
          "yoga14s"
          "y50_70"
          "matepad"
          "honor"
          "qemu"
        ];
      };
      Documents = {
        enable = true;
        id = "qjodx-kzvmj";
        path = "/home/xieby1/Documents";
        ignorePerms = false;
        devices = [
          "yoga14s"
          "y50_70"
          "matepad"
          "honor"
          "qemu"
        ];
        versioning = {
          type = "simple";
          params = {
            keep = "5";
            cleanoutDays = "0";
          };
        };

      };
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
          "qemu"
        ];
        versioning = {
          type = "simple";
          params = {
            keep = "5";
            cleanoutDays = "0";
          };
        };
      };
    };
  };

}
