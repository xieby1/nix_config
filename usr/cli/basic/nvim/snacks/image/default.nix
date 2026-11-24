# image-nvim vs snacks-nvim问题
# * image-nvim: 2026.11.24 更新
#   * 错位，大小太小
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
  nixpkgs.overlays = [(final: prev: {
    vimPlugins = prev.vimPlugins // {
      snacks-nvim = prev.vimPlugins.snacks-nvim.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          ./inline-height.patch
          ./inline-detach.patch
          ./inline-defer-edit.patch
          ./mermaid-pixel-size.patch
        ];
      });
    };
  })];
  my.nvim.snacks.setupArgs = /*lua*/ ''
    image = {
      enabled = true,
      cache = vim.fn.stdpath("cache") .. "/snacks/image-chromium",
      convert = {
        mermaid = function()
          local theme = vim.o.background == "light" and "redux-color" or "redux-dark-color"
          return { "-i", "{src}", "-o", "{file}", "-b", "transparent", "-t", theme, "-s", "{scale}" }
        end,
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
  '';
  my.nvim.snacks.extraLuaConfig = /*lua*/ ''
    -- by hermes + claude opus 4.6
    vim.api.nvim_create_user_command("SnacksImageToggle", function(opts)
      local cfg = Snacks.image.config
      cfg.enabled = not cfg.enabled
      if not cfg.enabled then
        Snacks.image.placement.clean()
        -- Remove doc autocmds and invalidate the inline attachment.
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.b[buf].snacks_image_attached then
            pcall(vim.api.nvim_del_augroup_by_name, "snacks.image.inline." .. buf)
            pcall(vim.api.nvim_del_augroup_by_name, "snacks.image.doc." .. buf)
            vim.b[buf].snacks_image_attached = nil
          end
        end
      else
        -- Re-attach doc images for current buffer
        Snacks.image.doc.attach(vim.api.nvim_get_current_buf())
      end
      if not opts.bang then
        vim.notify("snacks.image: " .. (cfg.enabled and "enabled" or "disabled"))
      end
    end, { bang = true })

    vim.api.nvim_create_user_command("SnacksImageRefresh", function()
      if Snacks.image.config.enabled then
        vim.cmd("SnacksImageToggle!")
      end
      vim.cmd("SnacksImageToggle!")
    end, {})
  '';
  programs.neovim = {
    extraWrapperArgs = [ "--prefix" "MAGICK_CONFIGURE_PATH" ":" "${delegates}" ];
    extraPackages = [
      pkgs.imagemagick
      pkgs.mermaid-cli
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
