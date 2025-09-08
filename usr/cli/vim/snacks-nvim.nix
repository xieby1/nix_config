{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.snacks-nvim;
      type = "lua";
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
    ];
  };
}
