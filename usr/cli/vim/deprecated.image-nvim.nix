# 问题
# * svg会变成png，非常不清晰，也没人提问题
# * （幻灯片里）图片多了非常卡，会显示不出来
# * 排版有问题，总有错位，issues说解决了，我这里用的最新版，仍然部分有问题
#
# 结论，不如用MarkdownPreview
{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimUtils.buildVimPlugin {
        name = "image-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "3rd";
          repo = "image.nvim";
          rev = "4c51d6202628b3b51e368152c053c3fb5c5f76f2";
          hash = "sha256-r3s19L0NcUfNTR1SQ98z8fEvhTxGRr4/jlicmbzmQZs=";
        };
      };
      type = "lua";
      config = ''
        require("image").setup({
          integrations = {
            markdown = {
              enabled = true,
              only_render_image_at_cursor = true,
            },
            html = {
              enabled = true,
              only_render_image_at_cursor = true,
              -- [Render HTML images in markdown files #234](https://github.com/3rd/image.nvim/issues/234)
              -- need html treesitter
              filetypes = { "html", "xhtml", "htm", "markdown" },
            },
            css = {
              enabled = true,
              only_render_image_at_cursor = true,
            },
          },
        })

        -- add :ImageToggle
        -- inspired by [How to toggle markdown image previews with a command?  #181](https://github.com/3rd/image.nvim/issues/181)
        vim.api.nvim_create_user_command('ImageToggle', function()
          local image = require("image")
          if image.is_enabled() then
            image.disable()
          else
            image.enable()
          end
        end, {})
      '';
    }];
    extraPackages = [ pkgs.imagemagick ];
  };
}
