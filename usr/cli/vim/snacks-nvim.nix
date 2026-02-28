# image-nvim vs snacks-nvim问题
# * image-nvim
#   * svg会变成png，非常不清晰，也没人提问题
#   * （幻灯片里）图片多了非常卡，会显示不出来
#   * 排版有问题，总有错位，issues说解决了，我这里用的最新版，仍然部分有问题
#   * 结论，不如用MarkdownPreview或snacks-nvim/image
{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.snacks-nvim;
      type = "lua";
      # TODO: [feature: Ability to disable/toggle image inline rendering for buffer #1739](https://github.com/folke/snacks.nvim/issues/1739#issuecomment-3413850508)
      config = /*lua*/ ''
        require("snacks").setup({
          image = {
            enabled = true,
            convert = {
              ---@type table<string,snacks.image.args>
              magick = (function() -- start of a local scope
                original = {
                  default = { "{src}[0]", "-scale", "1920x1080>" }, -- default for raster images
                  vector = { "-density", 192, "{src}[0]" }, -- used by vector images like svg
                  -- math = { "-density", 192, "{src}[0]", "-trim" },
                  pdf = { "-density", 192, "{src}[0]", "-background", "white", "-alpha", "remove", "-trim" },
                }
                -- if vim background is dark then negate the image color
                for _, opts in pairs(original) do
                  if vim.o.background == "dark" then
                    table.insert(opts, "-channel")
                    table.insert(opts, "RGB")
                    table.insert(opts, "-negate")
                  end
                end
                return original
              end)(), -- end of a local scope
            },
          },
          scroll = {
            enabled = true,
          },
        })
      '';
    }];
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
