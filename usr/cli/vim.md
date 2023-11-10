# Vim/Neovim in Nix/NixOS

## highlight color code

TLDR: vim-hexokinase isn't perfect but works.
It need works in `termguicolors` mode.
It is better to choose a color scheme which is visualized in gui mode.
And it is very tricky to setting colors in `termguicolors` & `notermguicolors` the same, which is insane.

It would be convenient, if color code can be visualised in editor, especially in web programming.
I found two candidates plugins to achieve this goal,
[vim-css-color](https://github.com/ap/vim-css-color),
[vim-hexokinase](https://github.com/RRethy/vim-hexokinase).

Vim-css-color is not compatible with tree-sitter, due to regex based highlight.
See [Github Issue: Neovim tree sitter support](https://github.com/ap/vim-css-color/issues/164) for details.
Vim-css-color sometimes cannot render same text color.
I need to scroll my vim viewport, then it **may** render color correctly.

Vim-hexokinase is good, but must depends on `termguicolors` is turned on.
`termguicolors` will enable 24-bit RGB color,
while originally vim uses Base16 color.
The result is the color theme you familiar with will be changed.

Here is the visual comparison between vim-css-color and vim-hexokinase.
I copy these text as html from my vim.

| vcc                                                                                | vcc tgc                                                                            | vh tgc                                                                             |
|:----------------------------------------------------------------------------------:|:----------------------------------------------------------------------------------:|:----------------------------------------------------------------------------------:|
| <span style="background-color:#FF0000"><font color="#EEEEEC">#ff0000</font></span> | <span style="background-color:#FF0000"><font color="#FFFFFF">#ff0000</font></span> | <span style="background-color:#FF0000"><font color="#FFFFFF">#ff0000</font></span> |
| <span style="background-color:#FF0000"><font color="#EEEEEC">#ff1111</font></span> | <span style="background-color:#FF1111"><font color="#FFFFFF">#ff1111</font></span> | <span style="background-color:#FF1111"><font color="#FFFFFF">#ff1111</font></span> |
| <span style="background-color:#FF0000"><font color="#EEEEEC">#ff2222</font></span> | <span style="background-color:#FF2222"><font color="#FFFFFF">#ff2222</font></span> | <span style="background-color:#FF2222"><font color="#FFFFFF">#ff2222</font></span> |
| <span style="background-color:#FF0000"><font color="#EEEEEC">#ff3333</font></span> | <span style="background-color:#FF3333"><font color="#FFFFFF">#ff3333</font></span> | <span style="background-color:#FF3333"><font color="#FFFFFF">#ff3333</font></span> |
| <span style="background-color:#FF5F5F"><font color="#2E3436">#ff4444</font></span> | <span style="background-color:#FF4444"><font color="#000000">#ff4444</font></span> | <span style="background-color:#FF4444"><font color="#FFFFFF">#ff4444</font></span> |
| <span style="background-color:#FF5F5F"><font color="#2E3436">#ff5555</font></span> | <span style="background-color:#FF5555"><font color="#000000">#ff5555</font></span> | <span style="background-color:#FF5555"><font color="#FFFFFF">#ff5555</font></span> |
| <span style="background-color:#FF5F5F"><font color="#2E3436">#ff6666</font></span> | <span style="background-color:#FF6666"><font color="#000000">#ff6666</font></span> | <span style="background-color:#FF6666"><font color="#FFFFFF">#ff6666</font></span> |
| <span style="background-color:#FF8787"><font color="#2E3436">#ff7777</font></span> | <span style="background-color:#FF7777"><font color="#000000">#ff7777</font></span> | <span style="background-color:#FF7777"><font color="#FFFFFF">#ff7777</font></span> |
| <span style="background-color:#FF8787"><font color="#2E3436">#ff8888</font></span> | <span style="background-color:#FF8888"><font color="#000000">#ff8888</font></span> | <span style="background-color:#FF8888"><font color="#FFFFFF">#ff8888</font></span> |
| <span style="background-color:#FF8787"><font color="#2E3436">#ff9999</font></span> | <span style="background-color:#FF9999"><font color="#000000">#ff9999</font></span> | <span style="background-color:#FF9999"><font color="#FFFFFF">#ff9999</font></span> |
| <span style="background-color:#FFAFAF"><font color="#2E3436">#ffaaaa</font></span> | <span style="background-color:#FFAAAA"><font color="#000000">#ffaaaa</font></span> | <span style="background-color:#FFAAAA"><font color="#000000">#ffaaaa</font></span> |
| <span style="background-color:#FFAFAF"><font color="#2E3436">#ffbbbb</font></span> | <span style="background-color:#FFBBBB"><font color="#000000">#ffbbbb</font></span> | <span style="background-color:#FFBBBB"><font color="#000000">#ffbbbb</font></span> |
| <span style="background-color:#FFD7D7"><font color="#2E3436">#ffcccc</font></span> | <span style="background-color:#FFCCCC"><font color="#000000">#ffcccc</font></span> | <span style="background-color:#FFCCCC"><font color="#000000">#ffcccc</font></span> |
| <span style="background-color:#FFD7D7"><font color="#2E3436">#ffdddd</font></span> | <span style="background-color:#FFDDDD"><font color="#000000">#ffdddd</font></span> | <span style="background-color:#FFDDDD"><font color="#000000">#ffdddd</font></span> |
| <span style="background-color:#EEEEEE"><font color="#2E3436">#ffeeee</font></span> | <span style="background-color:#FFEEEE"><font color="#000000">#ffeeee</font></span> | <span style="background-color:#FFEEEE"><font color="#000000">#ffeeee</font></span> |
| <span style="background-color:#FFFFFF"><font color="#2E3436">#ffffff</font></span> | <span style="background-color:#FFFFFF"><font color="#000000">#ffffff</font></span> | <span style="background-color:#FFFFFF"><font color="#000000">#ffffff</font></span> |
| <span style="background-color:#000000"><font color="#EEEEEC">#000000</font></span> | <span style="background-color:#000000"><font color="#FFFFFF">#000000</font></span> | <span style="background-color:#000000"><font color="#FFFFFF">#000000</font></span>
| <span style="background-color:#121212"><font color="#EEEEEC">#111111</font></span> | <span style="background-color:#111111"><font color="#FFFFFF">#111111</font></span> | <span style="background-color:#111111"><font color="#FFFFFF">#111111</font></span>
| <span style="background-color:#262626"><font color="#EEEEEC">#222222</font></span> | <span style="background-color:#222222"><font color="#FFFFFF">#222222</font></span> | <span style="background-color:#222222"><font color="#FFFFFF">#222222</font></span>
| <span style="background-color:#303030"><font color="#EEEEEC">#333333</font></span> | <span style="background-color:#333333"><font color="#FFFFFF">#333333</font></span> | <span style="background-color:#333333"><font color="#FFFFFF">#333333</font></span>
| <span style="background-color:#444444"><font color="#EEEEEC">#444444</font></span> | <span style="background-color:#444444"><font color="#FFFFFF">#444444</font></span> | <span style="background-color:#444444"><font color="#FFFFFF">#444444</font></span>
| <span style="background-color:#585858"><font color="#EEEEEC">#555555</font></span> | <span style="background-color:#555555"><font color="#FFFFFF">#555555</font></span> | <span style="background-color:#555555"><font color="#FFFFFF">#555555</font></span>
| <span style="background-color:#626262"><font color="#EEEEEC">#666666</font></span> | <span style="background-color:#666666"><font color="#FFFFFF">#666666</font></span> | <span style="background-color:#666666"><font color="#FFFFFF">#666666</font></span>
| <span style="background-color:#767676"><font color="#EEEEEC">#777777</font></span> | <span style="background-color:#777777"><font color="#FFFFFF">#777777</font></span> | <span style="background-color:#777777"><font color="#FFFFFF">#777777</font></span>
| <span style="background-color:#878787"><font color="#2E3436">#888888</font></span> | <span style="background-color:#888888"><font color="#000000">#888888</font></span> | <span style="background-color:#888888"><font color="#FFFFFF">#888888</font></span>
| <span style="background-color:#9E9E9E"><font color="#2E3436">#999999</font></span> | <span style="background-color:#999999"><font color="#000000">#999999</font></span> | <span style="background-color:#999999"><font color="#FFFFFF">#999999</font></span>
| <span style="background-color:#A8A8A8"><font color="#2E3436">#aaaaaa</font></span> | <span style="background-color:#AAAAAA"><font color="#000000">#aaaaaa</font></span> | <span style="background-color:#AAAAAA"><font color="#FFFFFF">#aaaaaa</font></span>
| <span style="background-color:#BCBCBC"><font color="#2E3436">#bbbbbb</font></span> | <span style="background-color:#BBBBBB"><font color="#000000">#bbbbbb</font></span> | <span style="background-color:#BBBBBB"><font color="#000000">#bbbbbb</font></span>
| <span style="background-color:#D0D0D0"><font color="#2E3436">#cccccc</font></span> | <span style="background-color:#CCCCCC"><font color="#000000">#cccccc</font></span> | <span style="background-color:#CCCCCC"><font color="#000000">#cccccc</font></span>
| <span style="background-color:#DADADA"><font color="#2E3436">#dddddd</font></span> | <span style="background-color:#DDDDDD"><font color="#000000">#dddddd</font></span> | <span style="background-color:#DDDDDD"><font color="#000000">#dddddd</font></span>
| <span style="background-color:#EEEEEE"><font color="#2E3436">#eeeeee</font></span> | <span style="background-color:#EEEEEE"><font color="#000000">#eeeeee</font></span> | <span style="background-color:#EEEEEE"><font color="#000000">#eeeeee</font></span>
| <span style="background-color:#FFFFFF"><font color="#2E3436">#ffffff</font></span> | <span style="background-color:#FFFFFF"><font color="#000000">#ffffff</font></span> | <span style="background-color:#FFFFFF"><font color="#000000">#ffffff</font></span>

Vim-css-color with out `termguicolors` cannot display color correctly (or say precisely),
if you dont believe your eye, see the source code of this page.

I think vim-hexokinase with a `termguicolors` toggle is a acceptable compromise.
Toggle `termguicolors` by `:set termguicolors!`.
I personally prefer to assign `<leader>c` to toggle `termguicolors`.

### cterm & gui

TLDR: I still haven't find a elegant solution to keep `termguicolors` and `notermguicolors` visually same.

neovim has 2 color schemes cterm & gui,
see `:h cterm-colors` & `:h gui-colors`.
Default sntax colors are different in these two schemes.
For example, `:verbose highlight Comment` returns

```vim
Comment        xxx ctermfg=14 guifg=#80a0ff
        Last set from /nix/store/pr1pwjjsm3k45rwi3w0xh2296rpymjlz-neovim-unwrapped-0.5.1/share/nvim/runtime/syntax/syncolor.vim
```

which means ctermfg uses the 14th color in ANSI colors,
while guifg use a hex color code.
The detailed setting is located in `${VIMRUNTIME}/syntax/syncolor.vim`.

I create a new syncolor.vim based the default one,
and modify the all ctermfg and guifg to same color name, like below.
The colors in two schemes are still different.

```vim
if !exists("syntax_cmd") || syntax_cmd == "on"
  " ":syntax on" works like in Vim 5.7: set colors but keep links
  command -nargs=* SynColor hi <args>
  command -nargs=* SynLink hi link <args>
else
  if syntax_cmd == "enable"
    " ":syntax enable" keeps any existing colors
    command -nargs=* SynColor hi def <args>
    command -nargs=* SynLink hi def link <args>
  elseif syntax_cmd == "reset"
    " ":syntax reset" resets all colors to the default
    command -nargs=* SynColor hi <args>
    command -nargs=* SynLink hi! link <args>
  else
    " User defined syncolor file has already set the colors.
    finish
  endif
endif

" Many terminals can only use six different colors (plus black and white).
" Therefore the number of colors used is kept low. It doesn't look nice with
" too many colors anyway.
" Careful with "cterm=bold", it changes the color to bright for some terminals.
" There are two sets of defaults: for a dark and a light background.
if &background == "dark"
  SynColor Comment	term=bold cterm=NONE ctermfg=Cyan ctermbg=NONE gui=NONE guifg=Cyan guibg=NONE
  SynColor Constant	term=underline cterm=NONE ctermfg=Magenta ctermbg=NONE gui=NONE guifg=Magenta guibg=NONE
  SynColor Special	term=bold cterm=NONE ctermfg=LightRed ctermbg=NONE gui=NONE guifg=LightRed guibg=NONE
  SynColor Identifier	term=underline cterm=bold ctermfg=Cyan ctermbg=NONE gui=bold guifg=Cyan guibg=NONE
  SynColor Statement	term=bold cterm=NONE ctermfg=Yellow ctermbg=NONE gui=NONE guifg=Yellow guibg=NONE
  SynColor PreProc	term=underline cterm=NONE ctermfg=LightBlue ctermbg=NONE gui=NONE guifg=LightBlue guibg=NONE
  SynColor Type		term=underline cterm=NONE ctermfg=LightGreen ctermbg=NONE gui=NONE guifg=LightGreen guibg=NONE
  SynColor Underlined	term=underline cterm=underline ctermfg=LightBlue gui=underline guifg=LightBlue
  SynColor Ignore	term=NONE cterm=NONE ctermfg=black ctermbg=NONE gui=NONE guifg=black guibg=NONE
else
  SynColor Comment	term=bold cterm=NONE ctermfg=DarkBlue ctermbg=NONE gui=NONE guifg=DarkBlue guibg=NONE
  SynColor Constant	term=underline cterm=NONE ctermfg=DarkRed ctermbg=NONE gui=NONE guifg=DarkBlue guibg=NONE
  SynColor Special	term=bold cterm=NONE ctermfg=DarkMagenta ctermbg=NONE gui=NONE guifg=DarkMagenta guibg=NONE
  SynColor Identifier	term=underline cterm=NONE ctermfg=DarkCyan ctermbg=NONE gui=NONE guifg=DarkCyan guibg=NONE
  SynColor Statement	term=bold cterm=NONE ctermfg=Brown ctermbg=NONE gui=bold guifg=Brown guibg=NONE
  SynColor PreProc	term=underline cterm=NONE ctermfg=DarkMagenta ctermbg=NONE gui=NONE guifg=DarkMagenta guibg=NONE
  SynColor Type		term=underline cterm=NONE ctermfg=DarkGreen ctermbg=NONE gui=NONE guifg=DarkGreen guibg=NONE
  SynColor Underlined	term=underline cterm=underline ctermfg=DarkMagenta gui=underline guifg=DarkMagenta
  SynColor Ignore	term=NONE cterm=NONE ctermfg=white ctermbg=NONE gui=NONE guifg=white guibg=NONE
endif
SynColor Error		term=reverse cterm=NONE ctermfg=White ctermbg=Red gui=NONE guifg=White guibg=Red
SynColor Todo		term=standout cterm=NONE ctermfg=Black ctermbg=Yellow gui=NONE guifg=Black guibg=Yellow
```

The Magenta is especially dazzling,
and cannot change it by below tries.

Refers to [Change Vim's terminal colors when termguicolors is set #2353](https://github.com/vim/vim/issues/2353),
[nvim-terminal-emulator-configuration](http://neovim.io/doc/user/nvim_terminal_emulator.html#nvim-terminal-emulator-configuration),

`let g:terminal_color_13 = '#AD7FA8' " Magenta` doesn't work.

Finally I choose to add a color-scheme manager,
and choose a theme which has both cterm & gui color scheme.
