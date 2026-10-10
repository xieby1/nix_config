{ config, lib, pkgs, ... }: {
  config = lib.mkIf config.isWSL2 {
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
    ];
  };
}
