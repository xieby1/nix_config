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
