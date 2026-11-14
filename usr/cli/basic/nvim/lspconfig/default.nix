{ nixdSrc }: # local-args
#MC # nvim-lspconfig
{ pkgs, lib, ... }: {
  imports = [
    ./c.nix
    # bash
    {programs.neovim={initLua="vim.lsp.enable('bashls')\n";extraPackages=[pkgs.bash-language-server];};}
    # html
    {programs.neovim={initLua="vim.lsp.enable('html')\n";extraPackages=[pkgs.vscode-langservers-extracted];};}
    (lib.modules.importApply ./nix {src = nixdSrc;})
    # python
    {programs.neovim={initLua="vim.lsp.enable('pyright')\n";extraPackages=[pkgs.pyright];};}
    # typos
    {programs.neovim={initLua="vim.lsp.enable('typos_lsp')\n";extraPackages=[pkgs.typos-lsp];};}
    # xml
    {programs.neovim={initLua="vim.lsp.enable('lemminx')\n";extraPackages=[pkgs.lemminx];};}
    # markdown
    {programs.neovim={initLua="vim.lsp.enable('marksman')\n";extraPackages=[pkgs.marksman];};
      # index .mdx files
      # https://github.com/artempyanykh/marksman/issues/114
      xdg.configFile."marksman/config.toml".text = ''
        [core]
        markdown.file_extensions = ["md", "markdown", "mdx"]
      '';
    }
    # language checker
    {programs.neovim={initLua="vim.lsp.enable('harper_ls')\n";extraPackages=[pkgs.harper];};}
    ./rust
    ./scala.nix
    ./typst.nix
    ./lua.nix
    ./vue.nix
    # zig
    {programs.neovim={initLua="vim.lsp.enable('zls')\n";extraPackages=[pkgs.zls pkgs.zig];};}
    # veryl: the pinned package lacks system libraries required by Rust's setup hook.
    # Remove this override once npins nixpkgs includes NixOS/nixpkgs#586901.
    {programs.neovim={initLua="vim.lsp.enable('veryl_ls')\n";extraPackages=[
      (pkgs.veryl.overrideAttrs (old: {
        buildInputs = (old.buildInputs or []) ++ [ pkgs.zstd pkgs.aws-lc ];
      }))
    ];};}
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
        vim.keymap.set('n', '[D', function() vim.diagnostic.jump({ count=-1, float=true, severity = { min = vim.diagnostic.severity.INFO } }) end)
        vim.keymap.set('n', ']D', function() vim.diagnostic.jump({ count= 1, float=true, severity = { min = vim.diagnostic.severity.INFO } }) end)
        vim.keymap.set('n', '<space>d', function() Snacks.picker.diagnostics_buffer() end)
        vim.keymap.set('n', '<space>D', function() Snacks.picker.diagnostics() end)
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
