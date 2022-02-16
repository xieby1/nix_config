# add this file to /etc/nixos/configuration.nix: imports
{ config, pkgs, ... }:

{
  imports = [
    ./sys/cli.nix
    ./sys/gui.nix
  ];

  nix.binaryCaches = [
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://cache.nixos.org/"
  ];

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";
  time.hardwareClockInLocalTime = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;
  users.users.root.hashedPassword = "$6$wRBpbr4zSTA/nh$XI/KUASw3mELIqyAxN1hUTWizz9ZBzPhP2u4HNDCA49h4KOWkZsyuiextyXkUti7jYsUHE9fTiRjGAoxBg0Gq/";
  users.users.xieby1 = {
    isNormalUser = true;
    createHome = true;
    hashedPassword = "$6$Y4KJxhdaJTT$RSolbCpaUKK2UW1cdnuH.8n1Ky9p0Lnx0MP36BxGX9Q2AeVMjCp.bZOsZ11w689je/785TFRQoVgicMiOfA9B.";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

}
