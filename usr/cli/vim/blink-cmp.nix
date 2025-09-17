#MC # completion
#MC # blink-cmp vs nvim-cmp
#MC # * as the config looks too hacking and too many issues remaining unsolved in github
#MC # * and nvim-cmp last maintain is 5 months ago, blink-cmp is 5 days ago.
#MC # * and minuet-ai-nvim delay in nvim-cmp and not solved, blink-cmp is async
{ pkgs, ... }: { programs.neovim = {
  plugins = [{
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
          default = { 'lsp', 'path', 'buffer', 'snippets', 'minuet' },
          providers = {
            minuet = {
              name = 'minuet',
              module = 'minuet.blink',
              async = true,
              -- Should match minuet.config.request_timeout * 1000,
              -- since minuet.config.request_timeout is in seconds
              timeout_ms = 3000,
              score_offset = 50, -- Gives minuet higher priority among suggestions
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
};}
