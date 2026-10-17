{ config, pkgs, lib, ... }:
let
  cfg = config.my.server.caddyAuthelia;
  yaml = pkgs.formats.yaml { };
  guestGroups = import ../guest-groups.nix { inherit lib; };

  # Users (owner + guests) live in the vault, not in the Nix store: argon2
  # hashes in /nix/store are world-readable and crackable offline. Same file the
  # guest teams/ssh keys are derived from, see ../guest-groups.nix.
  #
  # The path must be a plain string: interpolating a path value (`"${~/…}"`)
  # copies the whole directory into /nix/store, hashes included. `toString`
  # keeps it a string. Same spelling as in ../guest-groups.nix, so both read the
  # same file even when home.homeDirectory differs from $HOME (tests/build).
  vaultDir = toString ~/Gist/Vault/server;
  autheliaUsersFile = "${vaultDir}/users.jsonc";

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
