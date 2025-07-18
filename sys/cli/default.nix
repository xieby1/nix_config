#MC # sys/cli
#MC
#MC 本文件是NixOS的CLI配置。
#MC 主要包含两部分内容：
#MC
#MC * 系统环境管理（root的环境）
#MC * 系统配置

{ config, pkgs, ... }:

{
  #MC ## 系统环境管理（root的环境）

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    file
    wget
    fzf
    linuxPackages.perf
  ];

  # neovim
  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  programs.neovim.viAlias = true;
  programs.neovim.vimAlias = true;

  # ssh
  services.openssh = {
    enable = true;
    settings.X11Forwarding = true;
  };

  #MC ## 系统配置

  #MC 启用NTFS文件系统的支持。
  #MC 如此就可以在NixOS/Windows双系统的电脑上挂在Windows的分区啦。
  boot.supportedFilesystems = [ "ntfs" ];

  #MC 启用podman。
  #MC podman是一个十分好用的docker实现。
  #MC 支持用户态容器（不需要sudo），可以方便地挂在容器镜像的文件系统。
  virtualisation.podman.enable = true;

  #MC 配置binfmt，让非本地指令集的用户程序可以正常运行。
  #MC 比如在x86_64-linux上运行aarch64-linux的用户程序。
  #MC 注意：不能在配和本地一样的binfmt，比如不能在x86_64-linux的机器上配置x86_64-linux的binfmt。
  #MC 不然会出现奇怪的嵌套？你执行任何一条命令（x86_64-linux）都需要去调用qemu-x86_64，
  #MC 但qemu-x86_64本事也是x86_64-linux的，所以会死循环？
  #MC 我做了个实验：在x86_64-linux的NixOS中启用x86_64-linux的binfmt。
  #MC 任何程序都执行不了了，连关机都不行，只能强制重启。
  #MC 不过好在NixOS可以回滚，轻松复原实验前的环境。
  #MC 下面的`filterAttrs`就是用来保证不配置本地的binfmt。
  boot.binfmt.registrations = pkgs.lib.filterAttrs (n: v: n!=builtins.currentSystem) {
    x86_64-linux = {
      interpreter = "${pkgs.pkgsStatic.qemu-user}/bin/qemu-x86_64";
      magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00'';
      mask = ''\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
      wrapInterpreterInShell = false;
    };
    aarch64-linux = {
      interpreter = "${pkgs.pkgsStatic.qemu-user}/bin/qemu-aarch64";
      magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7\x00'';
      mask = ''\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\x00\xff\xfe\xff\xff\xff'';
      wrapInterpreterInShell = false;
    };
    riscv64-linux = {
      interpreter = "${pkgs.pkgsStatic.qemu-user}/bin/qemu-riscv64";
      magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xf3\x00'';
      mask = ''\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
      wrapInterpreterInShell = false;
    };
  };

  #MC 启用docdev。
  #MC 在home-manager中装devdoc似乎有问题，得在NixOS中装才行。
  #MC 之后有空再来详细研究。
  # Make sure devdoc outputs are installed.
  documentation.dev.enable = true;
  # Make sure legacy path is installed as well.
  environment.pathsToLink = [ "/share/gtk-doc" ];

  #MC 启用ADB，安卓搞事情必备。
  programs.adb.enable = true;
  users.users.xieby1.extraGroups = ["adbusers"];

  nix.settings.trusted-users = ["root" "xieby1"];

  zramSwap.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_xanmod;

  networking.firewall.enable = false;
}
