{ config, pkgs, lib, ... }:
let
  cfg = config.my.server.caddyAuthelia;
  yaml = pkgs.formats.yaml { };
  guestGroups = import ../guest-groups.nix;

  # Users (owner + guests) live in the vault, not in the Nix store: argon2
  # hashes in /nix/store are world-readable and crackable offline. Add a guest
  # with: authelia crypto hash generate argon2   (use the installed binary, a
  # different version than the service's has bitten the storage DB before.)
  #
  # The path is built as a string on purpose: interpolating the `~/…` path would
  # copy the file into /nix/store, defeating the point.
  vaultDir = "${config.home.homeDirectory}/Gist/Vault/server";
  autheliaUsersFile = "${vaultDir}/authelia-users.yml";

  # One rule per guest team, then the owner's rules. Authelia takes the first
  # matching rule, and a rule whose `subject` the user is not in does not
  # match, so a guest falls through to the default deny for anything outside
  # their team. Owner rules keep `subject = group:admins`, otherwise an
  # authenticated guest could reach /sixu, /web, the portal settings, …
  # A guest's group is the team name itself; guest-groups.nix asserts no team
  # is called "admins", which would otherwise match the owner rules below.
  accessRules = map (g: {
    domain = "xieby1.cn";
    resources = [ "^/repos/${g.name}(/.*)?$" ];
    subject = [ "group:admins" "group:${g.name}" ];
    policy = "two_factor";
  }) guestGroups ++ [
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
