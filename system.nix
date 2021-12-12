# add this file to /etc/nixos/configuration.nix: imports
{ config, pkgs, ... }:

{
  imports = [
    ./sys/cli.nix
    ./sys/gui.nix
  ];

  networking.hostName = "qemu"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.ens3.useDHCP = true;

  # Configure network proxy if necessary
  networking.proxy.default = "http://10.0.2.2:8889/";
  networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;
  users.users.root.hashedPassword = "$6$wRBpbr4zSTA/nh$XI/KUASw3mELIqyAxN1hUTWizz9ZBzPhP2u4HNDCA49h4KOWkZsyuiextyXkUti7jYsUHE9fTiRjGAoxBg0Gq/";
  users.users.xieby1 = {
    isNormalUser = true;
    createHome = true;
    hashedPassword = "$6$Y4KJxhdaJTT$RSolbCpaUKK2UW1cdnuH.8n1Ky9p0Lnx0MP36BxGX9Q2AeVMjCp.bZOsZ11w689je/785TFRQoVgicMiOfA9B.";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

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
      qemu = {
        id = "2SHHM4X-Q3WKRXD-5TUFXSE-BFXJ2M6-75XSW7V-J37IGTN-C6UM2HS-TK2V6QT";
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
          "qemu"
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

  #system.autoUpgrade.channel = ""

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
