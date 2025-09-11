#MC # lspconfig for plain text
{ pkgs, ... }: {
  programs.neovim = {
    extraLuaConfig = ''
      local paths = {
        -- vim.fn.stdpath("config") .. "/spell/ltex.dictionary.en-US.txt",
        vim.fn.expand("%:p:h") .. "/.ltexdict",
      }
      local words = {}
      for _, path in ipairs(paths) do
        local f = io.open(path)
        if f then
          for word in f:lines() do
            table.insert(words, word)
          end
        f:close()
        end
      end

      require('lspconfig').ltex.setup{
        settings = {
          ltex = {
            -- Supported languages:
            -- https://valentjn.github.io/ltex/settings.html#ltexlanguage
            -- https://valentjn.github.io/ltex/supported-languages.html#code-languages
            language = "en-US", -- "zh-CN" | "en-US",
            filetypes = { "bib", "gitcommit", "markdown", "org", "plaintex", "rst", "rnoweb", "tex", "pandoc" },
            dictionary = {
              ['en-GB'] = words,
            },
          },
        },
      }
      require('lspconfig')['ltex'].setup {}
    '';
    extraPackages = with pkgs; [
      ltex-ls
    ];
  };
}
