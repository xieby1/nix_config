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
    {programs.neovim={extraLuaConfig="vim.lsp.enable('rust_analyzer')\n";extraPackages=[pkgs.rust-analyzer];};}
  ];
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimPlugins.nvim-lspconfig;
      type = "lua";
      #MC ## Global mappings.
      config = /*lua*/ ''
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
      '';
    }];
  };
}
