{ ... }: {
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
}
