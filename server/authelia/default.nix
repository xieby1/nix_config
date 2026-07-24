{ config, pkgs, lib, ... }:
let
  cfg = config.my.server.caddyAuthelia;
  yaml = pkgs.formats.yaml { };

  autheliaUsersFile = yaml.generate "authelia-users.yml" {
    users.xieby1 = {
      displayname = "xieby1";
      password = "$argon2id$v=19$m=65536,t=3,p=4$LadudawpEhFJrQK4+X769A$5FWJdi2UjHmxf7VYtG6E3c/H1xalJGtXqkUAWBskEIY";
      email = "xieby1@outlook.com";
      groups = [ "admins" ];
    };
  };

  autheliaConfig = yaml.generate "authelia-configuration.yml" {
    theme = "auto";

    server.address = "tcp://127.0.0.1:9091/";

    log.level = "info";

    totp.issuer = "xieby1.cn";

    authentication_backend.file.path = "${autheliaUsersFile}";

    access_control = {
      default_policy = "deny";
      rules = [{
        domain = "xieby1.cn";
        resources = [
          "^/sixu/.*$"
          "^/syncthing/.*$"
        ];
        policy = "two_factor";
      }];
    };

    session.cookies = [{
      domain = "xieby1.cn";
      authelia_url = "https://xieby1.cn";
      default_redirection_url = "https://xieby1.cn/sixu/";
      same_site = "lax";
      # You can leave it idle during a workday without re-login.
      inactivity = "1d";
      # Even with activity, normal sessions must re-authenticate weekly.
      expiration = "1M";
      # It does not mean “remember my username”. It means “keep me authenticated longer”.
      # The maximum session lifetime when the user checks “Remember me” at login.
      remember_me = "6M";
    }];

    storage.local.path = "${config.xdg.configHome}/authelia/db.sqlite3";

    # Authelia says it "sent" an identity-verification one-time code when
    # registering a TOTP device. With the filesystem notifier, read it from
    # ~/.config/authelia/notification.txt on this server.
    notifier.filesystem.filename = "${config.xdg.configHome}/authelia/notification.txt";
  };
in {
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.authelia ];

    systemd.user.services.authelia = {
      Unit = {
        Description = "Authelia authentication portal";
        After = [ "network.target" ];
      };
      Install.WantedBy = [ "default.target" ];
      Service = {
        EnvironmentFile = ~/Gist/Vault/server/authelia.env;
        ExecStart = "${pkgs.authelia}/bin/authelia --config ${autheliaConfig}";
        Restart = "on-failure";
      };
    };
  };
}
