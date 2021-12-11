{ config, pkgs, ... }:

{
  # networking.hostName = "nixos"; # Define your hostname.
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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    file
    wget
    home-manager
  ];

  # neovim
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  programs.neovim.viAlias = true;
  programs.neovim.vimAlias = true;

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
