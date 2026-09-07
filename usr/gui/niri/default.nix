# Cons:
# * does not support viewport query and control (only support hard-coded touch gesture move view)!
# * does not support window movement (This is a common problem for wayland, in X11 there is wmctrl)
# * does not work well with ironbar: autohide double-trigger bug
{ pkgs, ... }: {
  imports = [
    ./config
  ];
  nixpkgs.overlays = [
    (final: prev: {
      niri = prev.niri.overrideAttrs (final: prev: {
        # # Implement release keybinds and modifier-only binds
        # # https://github.com/YaLTeR/niri/pull/2456/commits
        # src = pkgs.npinsed.de.niri;
        patches = [
          # Fix dingtalk screen casting.
          # https://forum.archlinuxcn.org/t/topic/15526/3
          # [Support shm sharing #1791](https://github.com/YaLTeR/niri/pull/1791)
          (pkgs.fetchurl {
            name = "shm-sharing";
            url = "https://github.com/wrvsrx/niri/compare/tag_support-shm-sharing_4~19..tag_support-shm-sharing_4.patch";
            sha256 = "sha256-LLbzjrUmCXOCqboGKFc19Lw7hyE2tMHJdadWtltfn5U=";
          })
        ];
        # # https://nixos.wiki/wiki/Rust#Using_overrideArgs_with_Rust_Packages
        # cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        #   src = final.src;
        #   hash = "sha256-bh3NrnlFz2m8aCCakgpblFrswh02ByJVPVgxBbTZ6ts=";
        # };
        # # Unnecessary due to cargoDeps having higher priority than cargoHash,
        # # but to make it explicitly that cargoHash is not used after overrideAttrs.
        # cargoHash = null;
      });
    })
  ];
  cachix_packages = [ pkgs.niri ];
  home.packages = [
    pkgs.niri
    # Use latest xwayland-satellite for wechat popup
    # https://github.com/Supreeeme/xwayland-satellite/pull/281
    pkgs.pkgsu.xwayland-satellite
  ];
  services.gnome-keyring.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    configPackages = [ pkgs.niri ];
  };
}
