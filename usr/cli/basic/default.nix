{
  # Enable optional CLI tooling omitted from the server profile.
  enableExtendedCLI ? true
}: # local args
{ lib, ... }: {
  imports = [
    ./starship.nix
    ./zsh
    ./nushell.nix
    ./git
    ./clash
    ./tailscale
    ./ssh.nix
    (lib.modules.importApply ./nvim {inherit enableExtendedCLI;})
    (lib.modules.importApply ./pi {inherit enableExtendedCLI;})
    ./syncthing.nix
  ];
  home.stateVersion = "25.05";

  news.display = "silent";

  programs.zsh.envExtra = /*bash*/ ''
    . ${toString ../../../scripts/bootstrap/main.sh}
  '';
  programs.nushell.extraEnv = ''
    source ${toString ../../../scripts/bootstrap/main.nu}
  '';
}
