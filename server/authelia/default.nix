{ config, pkgs, lib, ... }:
let
  cfg = config.my.server.caddyAuthelia;
  yaml = pkgs.formats.yaml { };

  autheliaUsersFile = yaml.generate "authelia-users.yml" {
    users.xieby1 = {
      displayname = "xieby1";
      password = "$argon2id$v=19$m=65536,t=3,p=4$LadudawpEhFJrQK4+X769A$5FWJdi2UjHmxf7VYtG6E3c/H1xalJGtXqkUAWBskEIY";
      email = "xieby1@example.invalid";
      groups = [ "admins" ];
    };
  };

  autheliaConfig = yaml.generate "authelia-configuration.yml" {
    theme = "auto";

    server.address = "tcp://127.0.0.1:9091/";

    log.level = "info";

    authentication_backend.file.path = "${autheliaUsersFile}";

    access_control = {
      default_policy = "deny";
      rules = [{
        domain = "127.0.0.1";
        resources = [ "^/app/.*$" ];
        policy = "one_factor";
      }];
    };

    session.cookies = [{
      domain = "127.0.0.1";
      authelia_url = "https://127.0.0.1:8443";
      default_redirection_url = "https://127.0.0.1:8443/app/";
      same_site = "lax";
      inactivity = "1h";
      expiration = "1d";
      remember_me = "1M";
    }];

    storage.local.path = "${config.xdg.configHome}/authelia/db.sqlite3";

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
