# Why do I need to enable home-manager systemd when username == root?
# Because I want to home-manager to manage the http and https ports.
# Only root can do it directly. So I need to run systemd under root.
let
  npinsed = import ~/.config/nixpkgs/npins;
  pkgs = import npinsed.nixpkgs {};
in pkgs.applyPatches {
  name = "home-manager-patched";
  src = npinsed.home-manager;
  postPatch = ''
    sed -i 's/mkIf (cfg.enable && config.home.username != "root")/mkIf cfg.enable/' modules/systemd.nix
  '';
}
