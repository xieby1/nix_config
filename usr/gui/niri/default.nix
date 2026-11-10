{ pkgs, ... }: {
  imports = [
    ./config
    ./win_align.nix
  ];
  nixpkgs.overlays = [
    (pkgs-final: pkgs-prev: {
      niri = pkgs-prev.niri.overrideAttrs (niri-final: niri-prev: {
        patches = niri-prev.patches ++ [
          # Fix dingtalk screen casting.
          # https://forum.archlinuxcn.org/t/topic/15526/3
          # [Support shm sharing #1791](https://github.com/YaLTeR/niri/pull/1791)
          (pkgs.fetchurl {
            name = "shm-sharing";
            url = "https://github.com/wrvsrx/niri/compare/tag_support-shm-sharing_4~19..tag_support-shm-sharing_4.patch";
            sha256 = "sha256-LLbzjrUmCXOCqboGKFc19Lw7hyE2tMHJdadWtltfn5U=";
          })
          # https://github.com/niri-wm/niri/discussions/1380
          ./focus-shrink.patch
        ];
      });
    })
  ];
  cachix_packages = [ pkgs.niri ];
  home.packages = [
    pkgs.niri
    pkgs.xwayland-satellite
  ];
  services.gnome-keyring.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    configPackages = [ pkgs.niri ];
  };
}
