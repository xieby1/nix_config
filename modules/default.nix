{ lib, ... }: {
  imports = [
    ./cachix.nix
    ./ai
  ];

  options = {
    isMinimalConfig = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    proxyPort = lib.mkOption {
      type = lib.types.number;
      default = 8889;
      description = "代理端口号，诸多网络程序需要用，比如clash和tailscale";
    };
    isGui = lib.mkOption {
      type = lib.types.bool;
      default = (builtins.getEnv "DISPLAY")!="";
    };
    isNixOnDroid = lib.mkOption {
      type = lib.types.bool;
      default = (builtins.getEnv "USER")=="nix-on-droid";
      description = ''
        默认值是通过用户名来判断是否是nix-on-droid。
      '';
    };
    isWSL2 = lib.mkOption {
      type = lib.types.bool;
      default = (builtins.getEnv "WSL_DISTRO_NAME")!="";
      description = ''
        默认值是通过环境变量`WSL_DISTRO_NAME`来判断是否是WSL2。
      '';
    };
  };
}
