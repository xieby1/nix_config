{ pkgs, ... }: {
  home.packages = with pkgs; [
    universal-ctags
  ];
  home.file.exclude_ctags = {
    text = ''
      # exclude ccls generated directories
      --exclude=.ccls*
    '';
    target = ".config/ctags/exclude.ctags";
  };
  home.file.scala_ctags = {
    target = ".config/ctags/scala.ctags";
    text = ''
      --langdef=Scala
      --langmap=Scala:.scala
      --regex-Scala=/^[ \t]*class[ \t]*([a-zA-Z0-9_]+)/\1/c,classes/
      --regex-Scala=/^[ \t]*object[ \t]*([a-zA-Z0-9_]+)/\1/o,objects/
      --regex-Scala=/^[ \t]*trait[ \t]*([a-zA-Z0-9_]+)/\1/t,traits/
      --regex-Scala=/^[ \t]*case[ \t]*class[ \t]*([a-zA-Z0-9_]+)/\1/r,cclasses/
      --regex-Scala=/^[ \t]*abstract[ \t]*class[ \t]*([a-zA-Z0-9_]+)/\1/a,aclasses/
      --regex-Scala=/^[ \t]*def[ \t]*([a-zA-Z0-9_=]+)[ \t]*.*[:=]/\1/m,methods/
      --regex-Scala=/[ \t]*val[ \t]*([a-zA-Z0-9_]+)[ \t]*[:=]/\1/V,values/
      --regex-Scala=/[ \t]*var[ \t]*([a-zA-Z0-9_]+)[ \t]*[:=]/\1/v,variables/
      --regex-Scala=/^[ \t]*type[ \t]*([a-zA-Z0-9_]+)[ \t]*[\[<>=]/\1/T,types/
      --regex-Scala=/^[ \t]*import[ \t]*([a-zA-Z0-9_{}., \t=>]+$)/\1/i,includes/
      --regex-Scala=/^[ \t]*package[ \t]*([a-zA-Z0-9_.]+$)/\1/p,packages/
    '';
  };
  programs.neovim = {
    extraConfig = ''
      "" tags support, ';' means upward search, referring to http://vimdoc.sourceforge.net/htmldoc/editing.html#file-searching
      set tags=./tags;
    '';
    plugins = [{
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
      #MC vim.lsp.config("clangd", {
      #MC   filetypes = { "c", "cc", "cpp", "c++", "objc", "objcpp", "cuda", "proto" }
      #MC })
      #MC vim.lsp.enable("clangd")
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
      plugin = pkgs.vimUtils.buildVimPlugin {
        name = "nvim-telescope-ctags-plus";
        src = pkgs.fetchFromGitHub {
          owner = "gnfisher";
          repo = "nvim-telescope-ctags-plus";
          rev = "455f24c0dcc6126c89cd3a3278e3fe322df061b1";
          hash = "sha256-P9uYkWvY4NzwlAxG40/0sNZoGEHezDhlYL/gKfBI/dA=";
        };
        doCheck = false;
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
    }];
  };
}
