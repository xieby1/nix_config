# # lz.n vs lazy.nvim:
# - lazy.nvim contains too many unnecessary features (unrelated to lazy)!
{ pkgs, ... }: {
  programs.neovim.plugins = [
    pkgs.vimPlugins.lz-n
    rec {
      plugin = pkgs.pkgsu.vimPlugins.copilot-lua;
      type = "lua";
      config = ''
        require("lz.n").load {
          [1] = "${plugin.pname}",
          cmd = "Copilot",
          after = function()
            require("copilot").setup()
          end,
        }
      '';
      optional = true;
    }
  ];
}
