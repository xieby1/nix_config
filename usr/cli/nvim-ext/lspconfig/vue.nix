{ pkgs, ... }: {
  programs.neovim = {
    extraLuaConfig = /*lua*/ ''
      local vue_language_server_path = '${pkgs.vue-language-server}/lib/language-tools/packages/language-server'
      vim.lsp.config('vtsls', {
        settings = {
          vtsls = {
            tsserver = {
              globalPlugins = {
                {
                  name = '@vue/typescript-plugin',
                  location = vue_language_server_path,
                  languages = { 'vue' },
                  configNamespace = 'typescript',
                },
              },
            },
          },
        },
        filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' },
      })
      vim.lsp.enable('vtsls')
      vim.lsp.enable('vue_ls')
    '';
    extraPackages = [ pkgs.vue-language-server pkgs.vtsls ];
  };
}
