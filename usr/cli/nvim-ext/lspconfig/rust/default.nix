{ pkgs, ... }: {
  programs.neovim={
    extraLuaConfig = /*lua*/ ''
      vim.lsp.config("rust_analyzer", {
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              -- goto definition of rust's lib needs this
              sysrootSrc = "${pkgs.rustPlatform.rustLibSrc}",
            },
          }
        },
      })
      vim.lsp.enable("rust_analyzer")
    '';
    extraPackages = [ pkgs.rust-analyzer ];
  };
  home.packages = [
    pkgs.cargo
    # prevent rust_analyzer throw error: `rust-analyzer: no sysroot [macro-error]`
    pkgs.rustc
  ];
}
