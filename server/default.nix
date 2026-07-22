{ lib, ... }:
{
  imports = [
    ./authelia
    ./caddy
    ./sixu.nix

    ../usr/modules
    ../usr/cli/basic
  ];

  options.my.server.caddyAuthelia.enable = lib.mkEnableOption "Caddy + Authelia prototype user services";

  config = {
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

    # TODO: deduplcate, as this snippet is also in user/default.nix
    programs.zsh.initContent = ''
      . ${toString ../scripts/bootstrap/main.sh}
    '';
    # envExtra gives non-interactive zsh, such as ssh 'cmd', the existing pin paths.
    # initContent runs the heavier bootstrap repair only for interactive shells.
    programs.zsh.envExtra = /*bash*/ ''
      if [[ -e "$HOME/.config/npins/nixpkgs" && -e "$HOME/.config/npins/home-manager" ]]; then
        export NIX_PATH="nixpkgs=$HOME/.config/npins/nixpkgs:home-manager=$HOME/.config/npins/home-manager:nixos-config=/etc/nixos/configuration.nix"
      fi
    '';

    # TODO: deduplcate
    services.syncthing.enable = true;

  };
}
