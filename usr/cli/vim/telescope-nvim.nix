#MC # telescope-nvim
{ config, pkgs, stdenv, lib, ... }:
let
  my-telescope-nvim = {
    plugin = pkgs.vimPlugins.telescope-nvim;
    config = ''
      " search relative to file
      "" https://github.com/nvim-telescope/telescope.nvim/pull/902
      nnoremap ff <cmd>lua require('telescope.builtin').find_files({cwd=require'telescope.utils'.buffer_dir()})<cr>
      nnoremap fF <cmd>lua require('telescope.builtin').find_files()<cr>
      nnoremap fb <cmd>lua require('telescope.builtin').buffers()<cr>
      nnoremap fh <cmd>lua require('telescope.builtin').help_tags()<cr>
      nnoremap ft <cmd>lua require('telescope.builtin').treesitter()<cr>
      nnoremap fc <cmd>lua require('telescope.builtin').command_history()<cr>
      nnoremap fC <cmd>lua require('telescope.builtin').commands()<cr>
    '';
  };
  # Problem: unable to fuzzy search parenthesis '('
  # https://github.com/nvim-telescope/telescope-fzf-native.nvim/issues/141
  my-telescope-fzf-native-nvim = {
    plugin = pkgs.vimPlugins.telescope-fzf-native-nvim;
    type = "lua";
    config = ''
      require('telescope').setup {
        extensions = {fzf = {}},
        defaults = {
          layout_strategy = 'vertical'
        }
      }
      require('telescope').load_extension('fzf')
    '';
  };
  #MC ## A bug in neovim or lspconfig?
  #MC
  #MC I want to jump to the definition of QEMU's `qemu_clock_get_ns` using ctags.
  #MC More specifically, when I press `g]` with my cursor under a `qemu_clock_get_ns` call,
  #MC neovim only lists one definition:
  #MC
  #MC ```vim
  #MC   # pri kind tag                file
  #MC   1 F   Functionqemu_clock_get_ns /home/xieby1/Codes/qemu/tests/unit/ptimer-test-stubs.c
  #MC                \%86l\%9c
  #MC Type number and <Enter> (q or empty cancels):
  #MC ```
  #MC
  #MC However, there should be two definitions!
  #MC After tweaking a lot, I found out that clangd's lspconfig config directly or indirectly causes this.
  #MC
  #MC ```lua
  #MC require('lspconfig').clangd.setup{
  #MC   filetypes = { "c", "cc", "cpp", "c++", "objc", "objcpp", "cuda", "proto" }
  #MC }
  #MC ```
  #MC
  #MC As long as the filetype of the current buffer is not clangd-related, ctags works correctly.
  #MC For example, if I `cd <qemu-source-code>`, then run `vim`, and finally `:ts qemu_clock_get_ns`,
  #MC I get the expected result:
  #MC
  #MC ```vim
  #MC   # pri kind tag                file
  #MC   1 F   f    qemu_clock_get_ns  tests/unit/ptimer-test-stubs.c
  #MC                typeref:typename:int64_t
  #MC                int64_t qemu_clock_get_ns(QEMUClockType type)
  #MC   2 F   f    qemu_clock_get_ns  util/qemu-timer.c
  #MC                typeref:typename:int64_t
  #MC                int64_t qemu_clock_get_ns(QEMUClockType type)
  #MC Type number and <Enter> (q or empty cancels):
  #MC ```
  #MC
  #MC I searched through neovim's and nvim-lspconfig's github issues but didn't find any related issues.
  #MC I also tried searching for the weird string `\%.*l\%.*c` (\%86l\%9c) in neovim and lspconfig source code,
  #MC but found nothing.
  #MC
  #MC As a result, I've decided to use a wrapper plugin for tags functionality.
  #MC
  #MC nvim-telescope has builtin support tags `:lua require'telescope.builtin'.tags{}`.
  #MC However it is VERY SLOW!
  #MC So, I choose to install a plugin: nvim-telescope-ctags-plus.
  nvim-telescope-ctags-plus = {
    plugin = pkgs.vimUtils.buildVimPlugin {
      name = "nvim-telescope-ctags-plus";
      src = pkgs.fetchFromGitHub {
        owner = "gnfisher";
        repo = "nvim-telescope-ctags-plus";
        rev = "455f24c0dcc6126c89cd3a3278e3fe322df061b1";
        hash = "sha256-P9uYkWvY4NzwlAxG40/0sNZoGEHezDhlYL/gKfBI/dA=";
      };
    };
    type = "lua";
    config =''
      require('telescope').load_extension('ctags_plus')

      -- in vimscript:
      -- nnoremap g] <cmd>lua require('telescope').extensions.ctags_plus.jump_to_tag()<cr>
      vim.keymap.set('n', 'g]', function()
        require('telescope').extensions.ctags_plus.jump_to_tag()
      end, { noremap = true, silent = true })
    '';
  };
  my-telescope-live-grep-args-nvim = {
    plugin = pkgs.vimPlugins.telescope-live-grep-args-nvim;
    type = "lua";
    config = ''
      require('telescope').load_extension("live_grep_args")

      -- nnoremap fg <cmd>lua require('telescope.builtin').live_grep({cwd=require'telescope.utils'.buffer_dir()})<cr>
      vim.keymap.set('n', 'fg', '<cmd>lua require("telescope").extensions.live_grep_args.live_grep_args({search_dirs={require"telescope.utils".buffer_dir()}})<cr>')
      -- nnoremap fG <cmd>lua require('telescope.builtin').live_grep()<cr>
      vim.keymap.set('n', 'fG', '<cmd>lua require("telescope").extensions.live_grep_args.live_grep_args()<cr>')
    '';
  };
in {
  programs.neovim = {
    plugins = [
      my-telescope-nvim
      my-telescope-fzf-native-nvim
      nvim-telescope-ctags-plus
      pkgs.vimPlugins.plenary-nvim
      my-telescope-live-grep-args-nvim
    ];
    extraPackages = with pkgs; [
      ripgrep
    ];
  };
}
