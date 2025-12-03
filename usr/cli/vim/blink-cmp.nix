#MC # completion
#MC # blink-cmp vs nvim-cmp
#MC # * as the config looks too hacking and too many issues remaining unsolved in github
#MC # * and nvim-cmp last maintain is 5 months ago, blink-cmp is 5 days ago.
#MC # * and minuet-ai-nvim delay in nvim-cmp and not solved, blink-cmp is async
# TODO: split providers into separate files
{ pkgs, ... }: { programs.neovim = {
  plugins = [(pkgs.vimUtils.buildVimPlugin {
    name = "blink-cmp-dictionary";
    version = "2025-09-17";
    # current nixpkgs version does not support capitalize_first & capitalize_whole_word
    # TODO: use latest version from nixpkgs when support above options
    src = pkgs.fetchFromGitHub {
      owner = "Kaiser-Yang";
      repo = "blink-cmp-dictionary";
      rev = "43b701fe9728a704bc63e4667c5d8b398bf129b2";
      hash = "sha256-szCNbYLWkJTAVGWz9iRFh7NfQfM5t5jcQHdQeKzBx30=";
    };
    doCheck = false;
  }) {
    # match unicode characters => match alphabet characters instead.
    # E.g. I don't want to completion a long CJK sentence.
    # E.g. I want alphabet next to CJK can be completed: "例子example"
    #      In original blink-fuzzy-lib, "example" cannot be completed.
    # (Due to the libblink_cmp_fuzzy being not easy to be patched,
    # the nix patch code becomes a large chunk as below.)
    plugin = pkgs.vimPlugins.blink-cmp.overrideAttrs (old: let
      postPatch = ''
        ## This is where texts being collected
        sed -i 's/\\p{L}/a-zA-Z/g' lua/blink/cmp/fuzzy/rust/lib.rs
        ## This is where trigger range is decided
        ## This change will break blink-fuzzy-lib check, so doCheck=false
        sed -i 's/\\p{L}/a-zA-Z/g' lua/blink/cmp/fuzzy/rust/keyword.rs
      '';
    in {
      # Here, postPatch does not effect blink-fuzzy-lib,
      # however, for consistency between source code and libblink_cmp_fuzzy.so,
      # I patch the source code as well.
      inherit postPatch;

      preInstall = let
        ext = pkgs.stdenv.hostPlatform.extensions.sharedLibrary;
        blink-fuzzy-lib = old.passthru.blink-fuzzy-lib.overrideAttrs { inherit postPatch; doCheck=false; };
      in ''
        mkdir -p target/release
        ln -s ${blink-fuzzy-lib}/lib/libblink_cmp_fuzzy${ext} target/release/libblink_cmp_fuzzy${ext}
      '';
    });
    type = "lua";
    config = /*lua*/ ''
      require("blink.cmp").setup({
        keymap = { preset = 'none',
          ['<Tab>']   = { 'select_next', 'fallback' },
          ['<S-Tab>'] = { 'select_prev', 'fallback' },
          ['<Up>']   = { function(cmp) return cmp.select_prev({ auto_insert = false }) end, 'fallback' },
          ['<Down>'] = { function(cmp) return cmp.select_next({ auto_insert = false }) end, 'fallback' },
          ['<CR>'] = { 'accept', 'fallback' },
          ['<A-1>'] = { function(cmp) cmp.accept({ index = 1 }) end },
          ['<A-2>'] = { function(cmp) cmp.accept({ index = 2 }) end },
          ['<A-3>'] = { function(cmp) cmp.accept({ index = 3 }) end },
          ['<A-4>'] = { function(cmp) cmp.accept({ index = 4 }) end },
          ['<A-5>'] = { function(cmp) cmp.accept({ index = 5 }) end },
          ['<A-6>'] = { function(cmp) cmp.accept({ index = 6 }) end },
          ['<A-7>'] = { function(cmp) cmp.accept({ index = 7 }) end },
          ['<A-8>'] = { function(cmp) cmp.accept({ index = 8 }) end },
          ['<A-9>'] = { function(cmp) cmp.accept({ index = 9 }) end },
          ['<A-0>'] = { function(cmp) cmp.accept({ index = 10 }) end },
          ['<A-y>'] = require('minuet').make_blink_map(),
        },
        completion = {
          documentation = { auto_show = true },
          menu = {
            draw = {
              columns = {
                {'item_idx'},
                {'kind_icon'}, {'label', 'label_description', gap = 1},
                {'source_name'},
              },
              components = {
                item_idx = {
                  text = function(ctx) return ctx.idx == 10 and '0' or ctx.idx >= 10 and ' ' or tostring(ctx.idx) end,
                  highlight = 'BlinkCmpSource' -- optional, only if you want to change its color
                },
              },
            },
          },
          list = { selection = { preselect = false }, },
        },
        sources = {
          default = {
            'lsp', 'path', 'buffer', 'snippets',
            'minuet',
            "dictionary"
          },
          providers = {
            -- > By default, the buffer source will only show when the LSP source returns no items
            -- Always show buffer completion, defaults to `{ 'buffer' }`
            lsp = { fallbacks = {}, },
            minuet = {
              name = 'minuet',
              module = 'minuet.blink',
              async = true,
              -- Should match minuet.config.request_timeout * 1000,
              -- since minuet.config.request_timeout is in seconds
              timeout_ms = 3000,
              score_offset = 50, -- Gives minuet higher priority among suggestions
            },
            -- blink-cmp-dictionary vs blink-cmp-dat-word
            -- former can handle capitalization proper, while latter cannot
            dictionary = {
              name = 'dict',
              module = 'blink-cmp-dictionary',
              min_keyword_length = 3,
              score_offset = -4, -- lower priority than buffer's -3
              opts = {
                dictionary_files = { "${pkgs.fetchurl {
                  url = "https://github.com/first20hours/google-10000-english/raw/bdf4c221bc120b0b7f6c3f1eff1cc1abb975f8d8/google-10000-english-no-swears.txt";
                  sha256 = "11pd0p6ckixr1b5qvi6qxj389wmzq1k42is1bm9fc2y3397y1cyn";
                }}" },
                dictionary_directories = { vim.fn.expand('~/Gist/dicts/') },
              },
            },
          },
        },
        cmdline = {
          -- TODO: blink-cmp cmdline cannot complete `'`,
          -- for example: `:h statusline` cannot complete to `:h 'statusline'`
          -- thus disable it currently
          enabled = false,
          keymap = { preset = 'inherit',
            ['<Tab>'] = { 'show_and_insert', 'select_next' },
            ['<CR>'] = { 'accept_and_enter', 'fallback' },
          },
          completion = { list = { selection = { preselect = false }, }, },
        },
      })
      vim.lsp.config('*', {
        capabilities = require('blink.cmp').get_lsp_capabilities(),
      })
    '';
  }];
};
}
