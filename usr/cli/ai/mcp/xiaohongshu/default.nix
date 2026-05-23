{ config, pkgs, ... }: let
  xiaohongshu-mcp = import pkgs.npinsed.ai.xiaohongshu-mcp {inherit pkgs;};
in {
  cachix_packages = [ xiaohongshu-mcp ];
  systemd.user.services.xiaohongshu-mcp = {
    Unit = {
      After = ["network.target"];
    };
    Install = {
      WantedBy = ["default.target"];
    };
    Service = {
      Environment = [
        "COOKIES_PATH=${config.home.homeDirectory}/Gist/Vault/AI/xhs-cookies/xby2.json"
      ];
      ExecStart = "${xiaohongshu-mcp}/bin/xiaohongshu-mcp";
    };
  };
}
