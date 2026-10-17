{
  pkgs ? import <nixpkgs> {}
}: pkgs.writeShellScriptBin "quick-phrase-fzf" ''
  ${pkgs.ripgrep}/bin/rg -I -N ''' \
    ${pkgs.fcitx5.src}/src/modules/quickphrase/quickphrase.d/emoji-eac.mb \
    ${pkgs.qt6Packages.fcitx5-chinese-addons.src}/im/pinyin/symbols \
    ${pkgs.fcitx5.src}/src/modules/quickphrase/quickphrase.d/latex.mb \
  | ${pkgs.fzf}/bin/fzf
''
