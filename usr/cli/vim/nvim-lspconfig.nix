#MC # nvim-lspconfig
{ config, pkgs, stdenv, lib, ... }:
let
  my-nvim-lspconfig = {
    # TODO: nixd is currently not supported by nixpkgs 23.05
    plugin = pkgs.pkgsu.vimPlugins.nvim-lspconfig;
    type = "lua";
    config = ''
      local lspconfig = require('lspconfig')

      -- Global mappings.
      -- See `:help vim.diagnostic.*` for documentation on any of the below functions
      vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
      vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

      -- Use LspAttach autocommand to only map the following keys
      -- after the language server attaches to the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

          -- Buffer local mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set('n', '<space>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)
          vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
          vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, opts)
        end,
      })

      -- ltex
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

      lspconfig.ltex.setup{
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
      -- end of ltex

      -- ccls
      lspconfig.ccls.setup{
        filetypes = {"c", "cc", "cpp", "c++", "objc", "objcpp"},
        rootPatterns = {".ccls", "compile_commands.json", ".git/", ".hg/"},
        cache = {
          directory = "/tmp/ccls",
        },
      }
      -- end of ccls

      -- nixd
      lspconfig.nixd.setup{}
      -- end of nixd

      -- html
      lspconfig.html.setup{}
      -- end of html

      -- python
      lspconfig.pyright.setup{}
      -- end of python

      -- Add additional capabilities supported by nvim-cmp
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Enable some language servers with the additional completion capabilities offered by nvim-cmp
      local servers = {
        'ltex',
        'ccls',
        'nixd',
        'html',
        'pyright',
      }
      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup {
          -- on_attach = my_custom_on_attach,
          capabilities = capabilities,
        }
      end
    '';
  };
in {
  programs.neovim = {
    plugins = [
      my-nvim-lspconfig
    ];
    extraPackages = with pkgs; [
      ccls
      ltex-ls
      pkgsu.nixd
      vscode-langservers-extracted # html
      pyright
    ];
  };
}
