{ config, ... }: {
  services.syncthing.enable = true;
  # 启用代理，因为有些syncthing的服务器似乎是被墙了的。
  systemd.user.services.syncthing.Service.Environment = [
    # https://docs.syncthing.net/users/proxying.html
    "http_proxy=http://127.0.0.1:${toString config.proxyPort}"
  ];
}
