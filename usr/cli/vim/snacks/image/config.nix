# Why not using default.nix, due to this file cannot represent this folder solely.
# The lua.nix is also need be imported into parent config.

# image-nvim vs snacks-nvim问题
# * image-nvim
#   * svg会变成png，非常不清晰，也没人提问题
#   * （幻灯片里）图片多了非常卡，会显示不出来
#   * 排版有问题，总有错位，issues说解决了，我这里用的最新版，仍然部分有问题
#   * 结论，不如用MarkdownPreview或snacks-nvim/image
{ pkgs, ... }: {
  programs.neovim = {
    extraPackages = [
      # for drawing math.tex as images
      (pkgs.texlive.combine {
        inherit (pkgs.texlive)
        scheme-basic
        standalone
        varwidth
        preview
        mathtools
        xcolor
      ;})
      pkgs.ghostscript
    ];
  };
}
