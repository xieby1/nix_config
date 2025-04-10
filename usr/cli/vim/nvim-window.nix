#MC # nvim-window: jump to nvim window
{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimUtils.buildVimPlugin {
        pname = "nvim-window";
        version = "2025-04-10";
        src = pkgs.fetchFromGitHub {
          owner = "yorickpeterse";
          repo = "nvim-window";
          rev = "322809de1cc5d76ea069daa70c4a45f575bf614d";
          hash = "sha256-FYUC0aGhhIh9V7kzjv/4hYODefdgOL9nzjfLFFKF4HE=";
        };
      };
      config = ''
        map <silent> <C-j>  :lua require('nvim-window').pick()<CR>
        map <silent> <C-w>j :lua require('nvim-window').pick()<CR>
      '';
    }];
  };
}
