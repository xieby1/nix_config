{ lib, ... }:
{
  imports = [
    ./authelia
    ./caddy
    ./circle.nix
    ./sixu.nix
    ./xingyao.nix

    # TODO: reuse ../usr as much as possible
    ../usr/cachix-push.nix
    ../usr/yq-merge
    ../usr/syncthing-gist-ignore.nix
    (lib.modules.importApply ../usr/cli/basic {enableExtendedCLI = false;})
  ];

  options.my.server.caddyAuthelia.enable = lib.mkEnableOption "Caddy + Authelia prototype user services";

  config = {
    # TODO: reuse ../usr as much as possible
    _module.args = import ../global-args {inherit lib;};

    targets.genericLinux.enable = true;
    targets.genericLinux.gpu.enable = false;

    # NOTE: These server daemons run as root Home Manager user services. The host
    # must keep root's systemd user manager alive after logout:
    #
    #   loginctl enable-linger root
    #
    # Without lingering, the last root SSH logout stops user@0.service, which
    # stops Caddy/Authelia and browsers may report PR_END_OF_FILE_ERROR.
    my.server.caddyAuthelia.enable = true;
  };
}
