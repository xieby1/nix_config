{ lib, ... }: {
  home.username = "xieby1";
  home.homeDirectory = "/home/xieby1";
  home.stateVersion = "25.05";
  imports = [(
    lib.modules.importApply ../../. {
      enableGraphics = false;
      enableExtendedCLI = false;
      enableServer = true;
    }
  )];
  news.display = "silent";
}
