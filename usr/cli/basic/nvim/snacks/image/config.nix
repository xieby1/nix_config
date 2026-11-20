# Why not using default.nix, due to this file cannot represent this folder solely.
# The lua.nix is also need be imported into parent config.

# image-nvim vs snacks-nvim问题
# * image-nvim
#   * svg会变成png，非常不清晰，也没人提问题
#   * （幻灯片里）图片多了非常卡，会显示不出来
#   * 排版有问题，总有错位，issues说解决了，我这里用的最新版，仍然部分有问题
#   * 结论，不如用MarkdownPreview或snacks-nvim/image
{ pkgs, ... }:
let
  # Chromium renders draw.io HTML labels that Inkscape/librsvg replace with fallback text; see README.md.
  svgDecoder = pkgs.writeShellScript "snacks-svg-decode" ''
    exec ${pkgs.python3}/bin/python3 ${./svg/main.py} \
      ${pkgs.chromium}/bin/chromium ${pkgs.imagemagick}/bin/magick "$@"
  '';
  delegates = pkgs.writeTextDir "delegates.xml" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <delegatemap>
      <delegate decode="svg:decode" stealth="True"
        command="${svgDecoder} '%s' '%s' '%s' '%s' '%s'"/>
    </delegatemap>
  '';
in {
  programs.neovim = {
    extraWrapperArgs = [ "--prefix" "MAGICK_CONFIGURE_PATH" ":" "${delegates}" ];
    extraPackages = [
      pkgs.imagemagick
      # for drawing math.tex as images
      # TODO: Is math disabled?
      (pkgs.texliveBasic.withPackages (p: [
        p.standalone
        p.varwidth
        p.preview
        p.mathtools
        p.xcolor
      ]))
      pkgs.ghostscript
    ];
  };
}
