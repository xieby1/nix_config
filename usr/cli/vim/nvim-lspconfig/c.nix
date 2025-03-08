#MC # lspconfig for C/C++ language
{ pkgs, ...}: {
  programs.neovim = {
    #MC ## C/C++
    #MC
    #MC ### Why use clangd instead of ccls?
    #MC
    #MC I encountered the problem below,
    #MC when view https://github.com/xieby1/openc910 smart_run/logical/tb/sim_main1.cpp
    #MC ```
    #MC LSP[ccls]: Error NO_RESULT_CALLBACK_FOUND: {
    #MC   error = {
    #MC     code = -32603,
    #MC     message = "failed to index /home/xieby1/Codes/openc910/smart_run/work/fputc.c"
    #MC   },
    #MC   id = 1,
    #MC   jsonrpc = "2.0"
    #MC }
    #MC ```
    #MC 
    #MC After some searching, I found
    #MC 
    #MC [GitHub: neovim: issue: lsp: NO_RESULT_CALLBACK_FOUND with ccls, rust-analyzer #15844](https://github.com/neovim/neovim/issues/15844)
    #MC 
    #MC sapphire-arches found:
    #MC 
    #MC > Something is causing the r-a LSP to send two replies with the same ID, see the attached log:
    #MC > lsp_debug.log
    #MC >
    #MC > It would be nice for the neovim LSP to handle this more gracefully (not filling my screen with garbage and taking focus), but I do think the bug is in R-A here? The problem seems to be related to editor.action.triggerParameterHints?
    #MC 
    #MC [GitHub: ccls: issue: I'm very confused about this question, it's about ccls or neovim built in LSP? #836](https://github.com/MaskRay/ccls/issues/836)
    #MC 
    #MC No one try to fix the two-replies problem in ccls.
    #MC However, nimaipatel recommanded [clangd_extensions](https://github.com/p00f/clangd_extensions.nvim).
    extraLuaConfig = ''
      require('lspconfig').clangd.setup{
        filetypes = { "c", "cc", "cpp", "c++", "objc", "objcpp", "cuda", "proto" }
      }
      require("clangd_extensions.inlay_hints").setup_autocmd()
      require("clangd_extensions.inlay_hints").set_inlay_hints()
    '';
    plugins = [
      pkgs.vimPlugins.clangd_extensions-nvim
    ];
    extraPackages = with pkgs; [
      clang-tools
    ];
  };
}
