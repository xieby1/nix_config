#MC # hbac-nvim: auto close buffer
{ config, pkgs, stdenv, lib, ... }:
let
  my-hbac = {
    plugin = pkgs.vimUtils.buildVimPlugin {
      name = "hbac.nvim";
      src = pkgs.npinsed.nvim.hbac;
      doCheck = false;
    };
    type = "lua";
    config = /*lua*/ ''
      require("hbac").setup({
        autoclose     = true, -- set autoclose to false if you want to close manually
        threshold     = 20, -- hbac will start closing unedited buffers once that number is reached
        close_command = function(bufnr)
          vim.api.nvim_buf_delete(bufnr, {})
        end,
        close_buffers_with_windows = false, -- hbac will close buffers with associated windows if this option is `true`
        telescope = {
          -- See #telescope-configuration below
          },
      })
    '';
  };
in {
  programs.neovim = {
    plugins = [
      my-hbac
    ];
  };
}
