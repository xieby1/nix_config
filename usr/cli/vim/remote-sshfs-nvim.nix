#MC # remote-sshfs.nvim: integrate sshfs into nvim
#MC
#MC In my opinion, sshfs provides a better experience than distant.nvim
{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimUtils.buildVimPlugin {
        pname = "remote-sshfs.nvim";
        version = "2025-2-10";
        src = pkgs.fetchFromGitHub {
          owner = "NOSDuco";
          repo = "remote-sshfs.nvim";
          rev = "03f6c40c4032eeb1ab91368e06db9c3f3a97a75d";
          hash = "sha256-vFEIISxhTIGSl9LzDYHuEIkjLGkU0y5XhfWI/i5DgN4=";
        };
      };
      type = "lua";
      config = ''
        require('telescope').load_extension 'remote-sshfs'
        require('remote-sshfs').setup{
          connections = {
            ssh_configs = {
              vim.fn.expand "$HOME" .. "/.ssh/config",
              vim.fn.expand "$HOME" .. "/Gist/Config/ssh.conf",
              "/etc/ssh/ssh_config",
            },
          },
        }
      '';
    }];
    extraPackages = [
      pkgs.sshfs
    ];
  };
}
