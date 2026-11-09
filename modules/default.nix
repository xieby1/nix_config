{ lib, ... }: {
  options = {
    isWSL2 = lib.mkOption {
      type = lib.types.bool;
      default = (builtins.getEnv "WSL_DISTRO_NAME")!="";
      description = ''
        默认值是通过环境变量`WSL_DISTRO_NAME`来判断是否是WSL2。
      '';
    };
  };
}
