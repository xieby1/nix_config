#MC # nvim-lspconfig
{ pkgs, ... }: {
  imports = [
    ./c.nix
    # bash
    {programs.neovim={extraLuaConfig="vim.lsp.enable('bashls')\n";extraPackages=[pkgs.bash-language-server];};}
    # html
    {programs.neovim={extraLuaConfig="vim.lsp.enable('html')\n";extraPackages=[pkgs.vscode-langservers-extracted];};}
    ./nix
    # python
    {programs.neovim={extraLuaConfig="vim.lsp.enable('pyright')\n";extraPackages=[pkgs.pyright];};}
    # typos
    {programs.neovim={extraLuaConfig="vim.lsp.enable('typos_lsp')\n";extraPackages=[pkgs.typos-lsp];};}
    # xml
    {programs.neovim={extraLuaConfig="vim.lsp.enable('lemminx')\n";extraPackages=[pkgs.lemminx];};}
    # markdown
    {programs.neovim={extraLuaConfig="vim.lsp.enable('marksman')\n";extraPackages=[pkgs.marksman];};
      # index .mdx files
      # https://github.com/artempyanykh/marksman/issues/114
      xdg.configFile."marksman/config.toml".text = ''
        [core]
        markdown.file_extensions = ["md", "markdown", "mdx"]
      '';
    }
    # language checker
    {programs.neovim={extraLuaConfig="vim.lsp.enable('harper_ls')\n";extraPackages=[pkgs.harper];};}
    ./rust
    ./scala.nix
    ./typst.nix
    ./lua.nix
  ];
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.nvim-lspconfig;
      type = "lua";
      #MC ## Global mappings.
      config = /*lua*/ ''
        vim.lsp.log.set_level("OFF")

        -- See `:help vim.diagnostic.*` for documentation on any of the below functions
        vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float)
        vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count=-1, float=true, severity = { min = vim.diagnostic.severity.WARN } }) end)
        vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count= 1, float=true, severity = { min = vim.diagnostic.severity.WARN } }) end)
        vim.keymap.set('n', '[D', function() vim.diagnostic.jump({ count=-1, float=true, }) end)
        vim.keymap.set('n', ']D', function() vim.diagnostic.jump({ count= 1, float=true, }) end)
        vim.keymap.set('n', '<space>d', Snacks.picker.diagnostics_buffer)
        vim.keymap.set('n', '<space>D', Snacks.picker.diagnostics)
        vim.diagnostic.config({
          float = {
            source = true,  -- Show the source (LSP server name)
          },
          signs = {
            text = {
              -- Do not show 'H' in the sign/number column.
              -- The main reason is harper_ls throws many hint diagnostics
              [vim.diagnostic.severity.HINT] = "",
            },
          },
        })

        -- Use LspAttach autocommand to only map the following keys
        -- after the language server attaches to the current buffer
        vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('UserLspConfig', {}),
          callback = function(_args)
            vim.lsp.inlay_hint.enable(true, { bufnr = _args.buf })
            vim.keymap.set('n', 'gd', Snacks.picker.lsp_definitions)
            vim.keymap.set('n', 'gD', Snacks.picker.lsp_declarations)
            vim.keymap.set('n', 'gt', Snacks.picker.lsp_type_definitions)
            vim.keymap.set('n', 'gr', Snacks.picker.lsp_references)
            vim.keymap.set('n', 'gi', Snacks.picker.lsp_implementations)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover)
            vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename)

            -- make sure lsp/vim native indent(share/nvim/runtime/indent/python.vim)
            -- don't override my setting
            vim.opt.tabstop = 2
            vim.opt.shiftwidth = 2
          end,
        })
      '';
    }];
  };
}
