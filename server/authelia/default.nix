{ config, pkgs, lib, ... }:
let
  cfg = config.my.server.caddyAuthelia;
  yaml = pkgs.formats.yaml { };
  guestGroups = import ../guest-groups.nix { inherit lib; };
  registry = import ~/Gist/Vault/server/users.nix;

  # The user database is generated from the vault registry, so its argon2 hashes
  # do land in /nix/store, which is world-readable. That trade-off and the
  # reasoning behind it are at the top of that file; do not add other secrets
  # there. authelia.env (session, storage-encryption, reset secrets) stays out,
  # as a string path: interpolating a path value (`"${~/…}"`) would copy the
  # whole directory into the store.
  vaultDir = toString ~/Gist/Vault/server;
  autheliaUsersFile = yaml.generate "authelia-users.yml" {
    # sshKeys is registry data for the ssh side; Authelia ignores unknown keys,
    # but the generated database should be the schema Authelia actually uses.
    users = builtins.mapAttrs (_: u: builtins.removeAttrs u [ "sshKeys" ]) registry;
  };

  # One rule per guest team, then the owner's rules. Authelia takes the first
  # matching rule, and a rule whose `subject` the user is not in does not
  # match, so a guest falls through to the default deny for anything outside
  # their team. Owner rules keep `subject = group:admins`, otherwise an
  # authenticated guest could reach /sixu, /web, the portal settings, …
  # A guest's group is the team name itself, derived from the user registry;
  # guest-groups.nix drops "admins" from that list, which would otherwise match
  # the owner rules below.
  accessRules = map (g: {
    domain = "xieby1.cn";
    resources = [ "^/repos/${g.name}(/.*)?$" ];
    subject = [ "group:admins" "group:${g.name}" ];
    policy = "two_factor";
  }) guestGroups.teams ++ [
    {
      domain = "xieby1.cn";
      resources = [ "^/repos(/.*)?$" ];
      subject = [ "group:admins" ];
      policy = "two_factor";
    }
    {
      domain = "xieby1.cn";
      subject = [ "group:admins" ];
      policy = "two_factor";
    }
  ];

  autheliaConfig = yaml.generate "authelia-configuration.yml" {
    theme = "auto";

    server.address = "tcp://127.0.0.1:9091/";

    log.level = "info";

    totp.issuer = "xieby1.cn";

    authentication_backend.file.path = autheliaUsersFile;

    access_control = {
      default_policy = "deny";
      rules = accessRules;
    };

    session.cookies = [{
      domain = "xieby1.cn";
      authelia_url = "https://xieby1.cn";
      default_redirection_url = "https://xieby1.cn/sixu/xby/";
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
        # Same string-not-path reason as autheliaUsersFile above.
        EnvironmentFile = "${vaultDir}/authelia.env";
        ExecStart = "${pkgs.authelia}/bin/authelia --config ${autheliaConfig}";
        Restart = "on-failure";
      };
    };
  };
}
