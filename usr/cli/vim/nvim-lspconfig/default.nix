#MC # nvim-lspconfig
{ pkgs, ... }: {
  imports = [
    ./c.nix
    # bash
    {programs.neovim={extraLuaConfig="vim.lsp.enable('bashls')\n";extraPackages=[pkgs.bash-language-server];};}
    # html
    {programs.neovim={extraLuaConfig="vim.lsp.enable('html')\n";extraPackages=[pkgs.vscode-langservers-extracted];};}
    # lua
    {programs.neovim={extraLuaConfig="vim.lsp.enable('lua_ls')\n";extraPackages=[pkgs.lua-language-server];};}
    # nix
    {programs.neovim={extraLuaConfig="vim.lsp.enable('nixd')\n";extraPackages=[pkgs.nixd];};}
    # python
    {programs.neovim={extraLuaConfig="vim.lsp.enable('pyright')\n";extraPackages=[pkgs.pyright];};}
    # typos
    {programs.neovim={extraLuaConfig="vim.lsp.enable('typos_lsp')\n";extraPackages=[pkgs.typos-lsp];};}
    # xml
    {programs.neovim={extraLuaConfig="vim.lsp.enable('lemminx')\n";extraPackages=[pkgs.lemminx];};}
    # markdown
    {programs.neovim={extraLuaConfig="vim.lsp.enable('marksman')\n";extraPackages=[pkgs.marksman];};}
    # language checker
    {programs.neovim={extraLuaConfig="vim.lsp.enable('harper_ls')\n";extraPackages=[pkgs.harper];};}
    ./rust.nix
    ./scala.nix
  ];
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.nvim-lspconfig;
      type = "lua";
      #MC ## Global mappings.
      config = /*lua*/ ''
        -- See `:help vim.diagnostic.*` for documentation on any of the below functions
        vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
        vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count=-1, float=true, severity = { min = vim.diagnostic.severity.WARN } }) end)
        vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count= 1, float=true, severity = { min = vim.diagnostic.severity.WARN } }) end)
        vim.keymap.set('n', '[D', function() vim.diagnostic.jump({ count=-1, float=true, }) end)
        vim.keymap.set('n', ']D', function() vim.diagnostic.jump({ count= 1, float=true, }) end)
        vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)
        vim.diagnostic.config({
          float = {
            source = true,  -- Show the source (LSP server name)
          }
        })

        -- Use LspAttach autocommand to only map the following keys
        -- after the language server attaches to the current buffer
        vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('UserLspConfig', {}),
          callback = function(ev)
            local opts = { buffer = ev.buf }
            local builtin = require("telescope.builtin")
            vim.keymap.set('n', 'gd', builtin.lsp_definitions, opts)
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
            vim.keymap.set('n', 'gt', builtin.lsp_type_definitions, opts)
            vim.keymap.set('n', 'gr', builtin.lsp_references, opts)
            vim.keymap.set('n', 'gi', builtin.lsp_implementations, opts)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)

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
