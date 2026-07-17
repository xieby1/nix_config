{ lib, ... }: {
  options.my.tailscale.devices = lib.mkOption {
    type = lib.types.attrsOf ( lib.types.submodule { options = {
      user = lib.mkOption {
        type = lib.types.str;
      };
      ip = lib.mkOption {
        type = lib.types.str;
      };
    };});
    readOnly = true;
    default = {
      yoga = {
        user = "xieby1";
        ip = "100.70.248.78";
      };
      techrevo = {
        user = "xieby1";
        ip = "100.70.252.78";
      };
      dell = {
        user = "xieby1";
        ip = "100.83.73.38";
      };
      aliyun = {
        user = "root";
        ip = "100.99.83.68";
      };
    };
  };
}
