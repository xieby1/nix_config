# 不足：niri还不支持viewport的查询和控制！
{ pkgs, ... }: let
  niri = pkgs.niri.overrideAttrs (final: prev: {
    # Implement release keybinds and modifier-only binds
    # https://github.com/YaLTeR/niri/pull/2456/commits
    # src = pkgs.fetchFromGitHub {
    #   owner = "flowerysong";
    #   repo = "niri";
    #   rev = "86edeb3b0b3d1a08d4d4f59705cbc99a732f5e95";
    #   hash = "sha256-VFOGkBKA03fIXf/BaXsN6CZqkwUTq1gPvTIGrEMmlTQ=";
    # };
    src = pkgs.fetchFromGitHub {
      owner = "flowerysong";
      repo = "niri";
      rev = "53447431c4adcfe1572fed5f39ebddc239ca381c";
      hash = "sha256-onL4kGGpNHYNIaU11hN440RruSJKcTblSi7CwqMbYeM=";
    };
    # https://nixos.wiki/wiki/Rust#Using_overrideArgs_with_Rust_Packages
    cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
      src = final.src;
      hash = "sha256-bh3NrnlFz2m8aCCakgpblFrswh02ByJVPVgxBbTZ6ts=";
    };
    # Unnecessary due to cargoDeps having higher priority than cargoHash,
    # but to make it explicitly that cargoHash is not used after overrideAttrs.
    cargoHash = null;
  });
in {
  imports = [
    ./config
  ];
  home.packages = [
    niri
    # Use latest xwayland-satellite for wechat popup
    # https://github.com/Supreeeme/xwayland-satellite/pull/281
    pkgs.pkgsu.xwayland-satellite
  ];
}
