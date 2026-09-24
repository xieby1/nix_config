{ config, ... }: {
  imports = [
    ./starship.nix
    ./zsh
    ./git
    ./clash
    ./tailscale
    ./ssh.nix
    ./nvim
    ./pi
  ];
  home.stateVersion = "25.05";

  news.display = "silent";

  programs.zsh.initContent = ''
    . ${toString ../../../scripts/bootstrap/main.sh}
  '';
  # envExtra gives non-interactive zsh, such as ssh 'cmd', the existing pin paths.
  # initContent runs the heavier bootstrap repair only for interactive shells.
  programs.zsh.envExtra = /*bash*/ ''
    if [[ -e "$HOME/.config/npins/nixpkgs" && -e "$HOME/.config/npins/home-manager" ]]; then
      export NIX_PATH="nixpkgs=$HOME/.config/npins/nixpkgs:home-manager=$HOME/.config/npins/home-manager${
        if config.isNixOnDroid
        then ":nix-on-droid=$HOME/.config/npins/nix-on-droid"
        else ":nixos-config=/etc/nixos/configuration.nix"
      }"
    fi
  '';
}
