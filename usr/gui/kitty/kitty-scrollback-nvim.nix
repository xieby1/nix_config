{ pkgs, ... }: {
  programs.neovim = {
    plugins = [{
      plugin = pkgs.vimUtils.buildVimPlugin {
        name = "kitty-scrollback.nvim";
        # TODO: use the kitty-scrollback.nvim from nixpkgs when it reachs 8.0.0
        src = pkgs.npinsed.kitty-scrollback-nvim;
      };
      type = "lua";
      config = /*lua*/''
        require('kitty-scrollback').setup({{
          callbacks = {
            after_ready = function()
              -- Disable the auto quit all after `"+y`:
              -- by clearing the autocommand that quits after yanking to clipboard
              vim.api.nvim_clear_autocmds({ group = 'KittyScrollBackNvimTextYankPost' })
            end,
          },
        }})
      '';
    }];
  };
  programs.kitty.extraConfig = ''
    # kitty-scrollback.nvim Kitten alias
    action_alias kitty_scrollback_nvim kitten '${pkgs.npinsed.kitty-scrollback-nvim}/python/kitty_scrollback_nvim.py'
    # Browse scrollback buffer in nvim
    map kitty_mod+h kitty_scrollback_nvim
    # Browse output of the last shell command in nvim
    map kitty_mod+g kitty_scrollback_nvim --config ksb_builtin_last_cmd_output
    # Show clicked command output in nvim
    mouse_map ctrl+shift+right press ungrabbed combine : mouse_select_command_output : kitty_scrollback_nvim --config ksb_builtin_last_visited_cmd_output
  '';
}
