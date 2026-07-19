{ ... }: {
  imports = [
    ./starship.nix
    ./zsh
    ./git.nix
    ./clash
    ./tailscale
    ./ssh.nix
    ./nvim
  ];
}
