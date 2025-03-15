{ config, ... }: {
  imports = [
    ./module.nix
  ];
  gnome-calendar = let
    caldavs = "${config.home.homeDirectory}/Gist/Vault/caldavs.nix";
  in if builtins.pathExists caldavs then import caldavs else {};
}
