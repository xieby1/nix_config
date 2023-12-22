{ config, pkgs, stdenv, lib, ... }:

let
  vim-ingo-library = pkgs.vimUtils.buildVimPlugin {
    name = "vim-ingo-library";
    src = pkgs.fetchFromGitHub {
      owner = "inkarkat";
      repo = "vim-ingo-library";
      rev = "8ea0e934d725a0339f16375f248fbf1235ced5f6";
      sha256 = "1rabyhayxswwh85lp4rzi2w1x1zbp5j0v025vsknzbqi0lqy32nk";
    };
  };
  my-vim-mark = {
    plugin = pkgs.vimUtils.buildVimPlugin {
      name = "vim-mark";
      src = pkgs.fetchFromGitHub {
        owner = "inkarkat";
        repo = "vim-mark";
        rev = "7f90d80d0d7a0b3696f4dfa0f8639bba4906d037";
        sha256 = "0n8r0ks58ixqv7y1afliabiqwi55nxsslwls7hni4583w1v1bbly";
      };
    };
    config = ''
      " clear highlight created by vim-mark
      nnoremap <leader><F3> :MarkClear<CR>
      " show all marks
      nnoremap <leader>M :Marks<CR>
    '';
  };
  DrawIt = pkgs.vimUtils.buildVimPlugin {
    name = "DrawIt";
    src = pkgs.fetchFromGitHub {
      owner = "vim-scripts";
      repo = "DrawIt";
      rev = "master"; # I believe it wont update ^_*, so its safe
      sha256 = "0yn985pj8dn0bzalwfc8ssx62m01307ic1ypymil311m4gzlfy60";
    };
  };
  # pluginWithConfigType is not displayed in `man home-configuration.nix`
  # see its avaiable config in `home-manager/modules/programs/neovim.nix`
  my-nvim-treesitter = {
    # Available languages see:
    #   https://github.com/nvim-treesitter/nvim-treesitter
    # see `pkgs.tree-sitter.builtGrammars.`
    # with `tree-sitter-` prefix and `-grammar` suffix removed
    plugin = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: with p; [
      c
      cpp
      python
      markdown
    ]);
    type = "lua";
    config = ''
      require 'nvim-treesitter.configs'.setup {
        -- TODO: https://github.com/NixOS/nixpkgs/issues/189838
        -- ensure_installed = {"c", "cpp", "python", "markdown"},
        ensure_installed = {},
        sync_install = false,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
          disable = {
            "nix",
          },
        },
      }
    '';
  };
  my-nvim-config-local = {
    plugin = pkgs.vimUtils.buildVimPlugin {
      name = "nvim-config-local";
      src = pkgs.fetchFromGitHub {
        owner = "klen";
        repo = "nvim-config-local";
        rev = "af59d6344e555917209f7304709bbff7cea9b5cc";
        sha256 = "1wg6g4rqpj12sjj0g1qxqgcpkzr7x82lk90lf6qczim97r3lj9hy";
      };
    };
    config = ''
      lua << EOF
      require('config-local').setup {
        lookup_parents = true,
        silent = true,
      }
      EOF
      augroup config-local
        autocmd BufEnter * nested lua require'config-local'.source()
      augroup END
    '';
  };
  my-leap-nvim = {
    plugin = pkgs.nur.repos.m15a.vimExtraPlugins.leap-nvim;
    type = "lua";
    config = ''
      require('leap').add_default_mappings()
    '';
  };
  my-telescope-nvim = {
    plugin = pkgs.vimPlugins.telescope-nvim;
    config = ''
      " search relative to file
      "" https://github.com/nvim-telescope/telescope.nvim/pull/902
      nnoremap ff <cmd>lua require('telescope.builtin').find_files({cwd=require'telescope.utils'.buffer_dir()})<cr>
      nnoremap fg <cmd>lua require('telescope.builtin').live_grep({cwd=require'telescope.utils'.buffer_dir()})<cr>
      nnoremap fF <cmd>lua require('telescope.builtin').find_files()<cr>
      nnoremap fG <cmd>lua require('telescope.builtin').live_grep()<cr>
      nnoremap fb <cmd>lua require('telescope.builtin').buffers()<cr>
      nnoremap fh <cmd>lua require('telescope.builtin').help_tags()<cr>
      nnoremap ft <cmd>lua require('telescope.builtin').treesitter()<cr>
      nnoremap fc <cmd>lua require('telescope.builtin').command_history()<cr>
      nnoremap fC <cmd>lua require('telescope.builtin').commands()<cr>
    '';
  };
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
  git-wip = pkgs.vimUtils.buildVimPlugin {
    name = "git-wip";
    src = pkgs.fetchFromGitHub {
      owner = "bartman";
      repo = "git-wip";
      rev = "1c095e93539261370ae811ebf47b8d3fe9166869";
      hash = "sha256-rjvg6sTOuUM3ltD3DuJqgBEDImLrsfdnK52qxCbu8vo=";
    };
    preInstall = "cd vim";
  };
  my-git-messenger-vim = {
    plugin = pkgs.vimPlugins.git-messenger-vim;
    config = ''
      " popup window no close automatically
      let g:git_messenger_close_on_cursor_moved=v:false
    '';
  };
  my-vim-floaterm = {
    plugin = pkgs.vimPlugins.vim-floaterm;
    config = ''
      nmap <Leader>t :FloatermNew --cwd=<buffer><CR>
      " let g:floaterm_keymap_new = '<Leader>t'
      let g:floaterm_width = 0.8
      let g:floaterm_height = 0.8
      " Set floaterm window's background
      hi Floaterm guibg=black
    '';
  };
  my-vista-vim = {
    plugin = pkgs.vimPlugins.vista-vim;
    config = ''
      let g:vista_default_executive = 'nvim_lsp'
    '';
  };
  my-vim-markdown = {
    plugin = pkgs.vimPlugins.vim-markdown;
    config = ''
      let g:vim_markdown_new_list_item_indent = 2
      let g:vim_markdown_no_default_key_mappings = 1
    '';
  };
  my-vim-hexokinase = {
    plugin = pkgs.vimPlugins.vim-hexokinase;
    config = ''
      let g:Hexokinase_highlighters = ['backgroundfull']
    '';
  };
  my-gitsigns-nvim = {
    plugin = pkgs.vimPlugins.gitsigns-nvim;
    type = "lua";
    config = ''
      require('gitsigns').setup {
        signcolumn = false,
        numhl      = true,
        linehl     = true,

        current_line_blame = true,

        -- keymaps
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
          end, {expr=true})

          map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
          end, {expr=true})

          -- Actions
          map({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>')
          map({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>')
          map('n', '<leader>hS', gs.stage_buffer)
          map('n', '<leader>hu', gs.undo_stage_hunk)
          map('n', '<leader>hR', gs.reset_buffer)
          map('n', '<leader>hp', gs.preview_hunk)
          map('n', '<leader>hb', function() gs.blame_line{full=true} end)
          map('n', '<leader>tb', gs.toggle_current_line_blame)
          map('n', '<leader>hd', gs.diffthis)
          map('n', '<leader>hD', function() gs.diffthis('~') end)
          map('n', '<leader>td', gs.toggle_deleted)

          -- Text object
          map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
        end
      }
    '';
  };
  my-color-scheme = {
    plugin = pkgs.vimPlugins.sonokai;
    config = ''
      nnoremap <leader>c :set termguicolors!<CR>
      set termguicolors

      let g:sonokai_transparent_background = 1

      let g:sonokai_colors_override = {
      \ 'black':    ['#111215', '237'],
      \ 'bg0':      ['#22232a', '235'],
      \ 'bg1':      ['#33353f', '236'],
      \ 'bg2':      ['#444754', '236'],
      \ 'bg3':      ['#555869', '237'],
      \ 'bg4':      ['#666a7e', '237'],
      \ 'grey':     ['#a5a5a6', '246'],
      \ 'grey_dim': ['#787879', '240'],
      \}

      " custom sonokai,
      " see section "How to use custom colors" of `:h sonokai.vim`
      function! s:sonokai_custom() abort
        let l:palette = sonokai#get_palette('default', {})
        call sonokai#highlight('StatusLine', l:palette.black, l:palette.fg, 'bold')
        call sonokai#highlight('StatusLineNC', l:palette.black, l:palette.grey, 'bold')
      endfunction
      augroup SonokaiCustom
        autocmd!
        autocmd ColorScheme sonokai call s:sonokai_custom()
      augroup END

      colorscheme sonokai
    '';
  };
  my-hbac = {
    plugin = pkgs.vimUtils.buildVimPlugin {
      name = "hbac.nvim";
      src = pkgs.fetchFromGitHub {
        owner = "axkirillov";
        repo = "hbac.nvim";
        rev = "e2e8333aa56ef43a577ac3a2a2e87bdf2f0d4cbb";
        hash = "sha256-7+e+p+0zMHPJjpnKNkL7QQHZJGQ1DFZ6fsofcsVNXaY=";
      };
    };
    type = "lua";
    config = ''
      require("hbac").setup({
        autoclose     = true, -- set autoclose to false if you want to close manually
        threshold     = 10, -- hbac will start closing unedited buffers once that number is reached
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
  my-winshift-nvim = {
    plugin = pkgs.vimPlugins.winshift-nvim;
    type = "lua";
    config = ''
      -- Lua
      require("winshift").setup({
        highlight_moving_win = true,  -- Highlight the window being moved
        focused_hl_group = "Visual",  -- The highlight group used for the moving window
        -- moving_win_options = {
        --   -- These are local options applied to the moving window while it's
        --   -- being moved. They are unset when you leave Win-Move mode.
        --   wrap = true,
        --   cursorline = false,
        --   cursorcolumn = false,
        --   colorcolumn = "",
        -- },
        keymaps = {
          disable_defaults = false, -- Disable the default keymaps
          win_move_mode = {
            ["h"] = "left",
            ["j"] = "down",
            ["k"] = "up",
            ["l"] = "right",
            ["H"] = "far_left",
            ["J"] = "far_down",
            ["K"] = "far_up",
            ["L"] = "far_right",
            ["<left>"] = "left",
            ["<down>"] = "down",
            ["<up>"] = "up",
            ["<right>"] = "right",
            ["<S-left>"] = "far_left",
            ["<S-down>"] = "far_down",
            ["<S-up>"] = "far_up",
            ["<S-right>"] = "far_right",
          },
        },
        ---A function that should prompt the user to select a window.
        ---
        ---The window picker is used to select a window while swapping windows with
        ---`:WinShift swap`.
        ---@return integer? winid # Either the selected window ID, or `nil` to
        ---   indicate that the user cancelled / gave an invalid selection.
        window_picker = function()
          return require("winshift.lib").pick_window({
            -- A string of chars used as identifiers by the window picker.
            picker_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
            filter_rules = {
              -- This table allows you to indicate to the window picker that a window
              -- should be ignored if its buffer matches any of the following criteria.
              cur_win = true, -- Filter out the current window
              floats = true,  -- Filter out floating windows
              filetype = {},  -- List of ignored file types
              buftype = {},   -- List of ignored buftypes
              bufname = {},   -- List of vim regex patterns matching ignored buffer names
            },
            ---A function used to filter the list of selectable windows.
            ---@param winids integer[] # The list of selectable window IDs.
            ---@return integer[] filtered # The filtered list of window IDs.
            filter_func = nil,
          })
        end,
      })

      vim.keymap.set('n', '<C-W>m', '<Cmd>WinShift<CR>')
    '';
  };
in
{
  imports = [(let
    jre_with_proxy = pkgs.callPackage ./jre_with_proxy.nix {
      jre = pkgs.openjdk8_headless;
      proxyHost = "127.0.0.1";
      proxyPort = "${toString config.proxyPort}";
    };
    my-nvim-metals = {
      plugin = pkgs.vimPlugins.nvim-metals;
      type = "lua";
      config = ''
        -- lspconfig.metals.setup{}
        local metals_config = require("metals").bare_config()
        metals_config.find_root_dir_max_project_nesting = 2
        metals_config.root_patterns = {
          "build.sbt",
        }
        metals_config.settings = {
          showImplicitArguments = true,
          excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
          serverProperties = {
            "-Dhttps.proxyHost=127.0.0.1",
            "-Dhttps.proxyPort=${toString config.proxyPort}",
            "-Dhttp.proxyHost=127.0.0.1",
            "-Dhttp.proxyPort=${toString config.proxyPort}",
          },
          -- see `:h metalsBinaryPath`, "Another setting for you crazy Nix kids." Hahaha!
          metalsBinaryPath = "${pkgs.metals.override {jre = jre_with_proxy;}}/bin/metals",
          javaHome = "${jre_with_proxy}",
        }
        metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()
        -- Autocmd that will actually be in charging of starting the whole thing
        local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
        vim.api.nvim_create_autocmd("FileType", {
          group = nvim_metals_group,
          pattern = { "scala", "sbt" },
          callback = function()
            require("metals").initialize_or_attach(metals_config)
          end,
        })
      '';
    };
  in {
    programs.neovim = {
      plugins = with pkgs.vimPlugins; [
        my-nvim-metals
      ];
      extraPackages = with pkgs; [
        (coursier.override {
          jre = jre_with_proxy;
        })
      ];

    };
    # nvim-metals proxy for bloop
    home.file.jvmopts = {
      text = ''
        -Dhttps.proxyHost=127.0.0.1
        -Dhttps.proxyPort=${toString config.proxyPort}
        -Dhttp.proxyHost=127.0.0.1
        -Dhttp.proxyPort=${toString config.proxyPort}
      '';
      target = ".bloop/.jvmopts";
    };
  }) (let
    my-conform-nvim = let
      nvim_doc_tools = pkgs.fetchFromGitHub {
        owner = "stevearc";
        repo = "nvim_doc_tools";
        rev = "2fe4503c704ac816efdbbbf70d0c070ed3052bba";
        sha256 = "sha256-PtUMBHB+1IV8Q2L6pYKKvx7bliq63Z+2v8IDC5mvAeo=";
      };
      nvim-typecheck-action = pkgs.fetchFromGitHub {
        owner = "stevearc";
        repo = "nvim-typecheck-action";
        rev = "0a5ddc13b800c50bac699edd443f494a089824cd";
        sha256 = "sha256-Mzzt2A0WCeaeIDiCWgHii+RUQNlQssPxK5/LVaEgpbU=";
      };
      neodev_nvim = pkgs.fetchFromGitHub {
        owner = "folke";
        repo = "neodev.nvim";
        rev = "627b5b543f4df551fcddb99c17a8e260c453400d";
        sha256 = "sha256-S8/dUOcVPUeh54ZTELql/H5nW3DghpCtWzyxaPjZbCw=";
      };
    in {
      plugin = pkgs.vimUtils.buildVimPlugin {
        name = "conform.nvim";
        src = pkgs.fetchFromGitHub {
          owner = "stevearc";
          repo = "conform.nvim";
          rev = "a36c68d2cd551e49883ddb2492c178d915567f58";
          sha256 = "sha256-aul/6sQZMljF3nc+WrRhVEObytu4wkoVyTM5HognK7E=";
        };
        buildInputs = with pkgs; [
          python3Packages.pyparsing
          python3
          luajitPackages.luacheck
          stylua
          git
          lua-language-server
        ];
        preBuild = ''
          sed -i 's/all: doc lint test/all: doc/g' Makefile

          mkdir -p scripts/nvim_doc_tools
          cp -r ${nvim_doc_tools}/* scripts/nvim_doc_tools/
          # disable ShaDa
          sed -i 's/nvim --headless/nvim --headless -i NONE/' scripts/nvim_doc_tools/util.py

          mkdir -p scripts/nvim-typecheck-action
          cp -r ${nvim-typecheck-action}/* scripts/nvim-typecheck-action/
          patchShebangs scripts/nvim-typecheck-action/

          mkdir -p scripts/nvim-typecheck-action/libs/neodev.nvim
          cp -r ${neodev_nvim}/* scripts/nvim-typecheck-action/libs/neodev.nvim/
        '';
      };
      type = "lua";
      config = ''
        require("conform").setup({
          formatters_by_ft = {
            nix = { "nixfmt" },
            c = { "clang_format" },
            cpp = { "clang_format" },
          },
        })

        -- refer to https://github.com/stevearc/conform.nvim/blob/master/doc/recipes.md#format-command
        vim.api.nvim_create_user_command("TrimWhitespace", function(args)
          local range = nil
          if args.count ~= -1 then
            local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
            range = {
              start = { args.line1, 0 },
              ["end"] = { args.line2, end_line:len() },
            }
          end
          require("conform").format({ formatters = {"trim_whitespace"}, range = range })
        end, { range = true })
        vim.keymap.set({'n','v'}, '<leader>f', ':TrimWhitespace<CR>')

        vim.api.nvim_create_user_command("Format", function(args)
          local range = nil
          if args.count ~= -1 then
            local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
            range = {
              start = { args.line1, 0 },
              ["end"] = { args.line2, end_line:len() },
            }
          end
          require("conform").format({ async = true, lsp_fallback = true, range = range })
        end, { range = true })
        vim.keymap.set({'n','v'}, '<leader>F', ':Format<CR>')
      '';
    };
  in {
    programs.neovim = {
      plugins = with pkgs.vimPlugins; [
        my-conform-nvim
      ];
      extraPackages = with pkgs; [
        nixfmt
        clang-tools
      ];
    };
  }) (let
    my-nvim-lspconfig = {
      # TODO: nixd is currently not supported by nixpkgs 23.05
      plugin = pkgs.pkgsu.vimPlugins.nvim-lspconfig;
      type = "lua";
      config = ''
        local lspconfig = require('lspconfig')

        -- Global mappings.
        -- See `:help vim.diagnostic.*` for documentation on any of the below functions
        vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
        vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

        -- Use LspAttach autocommand to only map the following keys
        -- after the language server attaches to the current buffer
        vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('UserLspConfig', {}),
          callback = function(ev)
            -- Enable completion triggered by <c-x><c-o>
            vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

            -- Buffer local mappings.
            -- See `:help vim.lsp.*` for documentation on any of the below functions
            local opts = { buffer = ev.buf }
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
            vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
            vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
            vim.keymap.set('n', '<space>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)
            vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
            vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
            vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
            vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, opts)
          end,
        })

        -- ltex
        local paths = {
          -- vim.fn.stdpath("config") .. "/spell/ltex.dictionary.en-US.txt",
          vim.fn.expand("%:p:h") .. "/.ltexdict",
        }
        local words = {}
        for _, path in ipairs(paths) do
          local f = io.open(path)
          if f then
            for word in f:lines() do
              table.insert(words, word)
            end
          f:close()
          end
        end

        lspconfig.ltex.setup{
          settings = {
            ltex = {
              -- Supported languages:
              -- https://valentjn.github.io/ltex/settings.html#ltexlanguage
              -- https://valentjn.github.io/ltex/supported-languages.html#code-languages
              language = "en-US", -- "zh-CN" | "en-US",
              filetypes = { "bib", "gitcommit", "markdown", "org", "plaintex", "rst", "rnoweb", "tex", "pandoc" },
              dictionary = {
                ['en-GB'] = words,
              },
            },
          },
        }
        -- end of ltex

        -- ccls
        lspconfig.ccls.setup{
          filetypes = {"c", "cc", "cpp", "c++", "objc", "objcpp"},
          rootPatterns = {".ccls", "compile_commands.json", ".git/", ".hg/"},
          cache = {
            directory = "/tmp/ccls",
          },
        }
        -- end of ccls

        -- nixd
        lspconfig.nixd.setup{}
        -- end of nixd

        -- Add additional capabilities supported by nvim-cmp
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        -- Enable some language servers with the additional completion capabilities offered by nvim-cmp
        local servers = { 'ltex', 'ccls', 'nixd'}
        for _, lsp in ipairs(servers) do
          lspconfig[lsp].setup {
            -- on_attach = my_custom_on_attach,
            capabilities = capabilities,
          }
        end
      '';
    };
  in {
    programs.neovim = {
      plugins = with pkgs.vimPlugins; [
        my-nvim-lspconfig
      ];
      extraPackages = with pkgs; [
        ccls
        ltex-ls
        pkgsu.nixd
      ];
    };
  }) (let
    my-nvim-cmp = {
      plugin = pkgs.vimPlugins.nvim-cmp;
      type = "lua";
      config = ''
        local cmp = require'cmp'

        cmp.setup({
          snippet = {
            -- REQUIRED - you must specify a snippet engine
            expand = function(args)
              require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
            ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Down
            -- C-b (back) C-f (forward) for snippet placeholder navigation.
            ['<C-Space>'] = cmp.mapping.complete(),

            -- https://github.com/hrsh7th/nvim-cmp/issues/1753
            -- The "Safely select entries with <CR>" example from wiki does not work correctly in command mode
            ["<CR>"] = cmp.mapping({
              i = function(fallback)
                if cmp.visible() and cmp.get_active_entry() then
                  cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                else
                  fallback()
                end
              end,
              s = cmp.mapping.confirm({ select = true }),
              c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
            }),

            ['<Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              else
                fallback()
              end
            end, { 'i', 's' }),
            ['<S-Tab>'] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              else
                fallback()
              end
            end, { 'i', 's' }),
          }),
          sources = cmp.config.sources({{
            name = 'nvim_lsp',
          }}, {{
            name = 'luasnip',
          }}, {{
            name = 'buffer',
            option = {
              -- completion using words from visible buffers
              get_bufnrs = function()
                local bufs = {}
                for _, win in ipairs(vim.api.nvim_list_wins()) do
                  bufs[vim.api.nvim_win_get_buf(win)] = true
                end
                return vim.tbl_keys(bufs)
              end
            },
          }}, {{
            name = 'path',
      '' + pkgs.lib.optionalString (builtins.currentSystem=="x86_64-linux") ''
          }}, {{
            name = 'cmp_tabnine',
      '' + ''
          }})
        })
      '';
    };
    my-cmp-tabnine = {
      plugin = pkgs.vimPlugins.cmp-tabnine;
      type = "lua";
      config = ''
        local tabnine = require('cmp_tabnine.config')

        tabnine:setup({
          max_lines = 1000,
          max_num_results = 20,
          sort = true,
          run_on_every_keystroke = true,
          snippet_placeholder = '..',
          ignored_file_types = {
            -- default is not to ignore
            -- uncomment to ignore in lua:
            -- lua = true
          },
          show_prediction_strength = false
        })
      '';
    };
  in {
    programs.neovim = {
      plugins = with pkgs.vimPlugins; [
        my-nvim-cmp
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        luasnip
        cmp_luasnip
      ] ++ pkgs.lib.optional (builtins.currentSystem == "x86_64-linux") my-cmp-tabnine;
      extraPackages = with pkgs; [
      ];
    };
  })];

  # neovim
  programs.bash.shellAliases.view = "nvim -R";
  # nvim as manpager
  ## see nvim `:h :Man`
  ## nvim manpage huge mange is SLOW! E.g. man configuration.nix
  programs.bash.shellAliases.nman = "env MANPAGER='nvim +Man!' man";
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraConfig = ''
      " vim
      "" Highlight searches
      set hlsearch
      nnoremap <F3> :nohlsearch<CR>
      "" Show line number
      set number
      "" Always show the signcolumn, otherwise it would shift the text each time
      "" diagnostics appear/become resolved
      set signcolumn=number
      "" indent
      "set smartindent " not good, indentation in empty line cannot be auto removed
      """ show existing tab with 4 spaces width
      set tabstop=4
      """ when indenting with '>', use 4 spaces width
      set shiftwidth=4
      """ specicial indent
      au FileType markdown setlocal shiftwidth=2 tabstop=2
      """ On pressing tab, insert 4 spaces
      set expandtab
      """ line wrap with ident
      set breakindent
      """" horizontally scroll 4 characters
      nnoremap z<left> 4zh
      nnoremap z<right> 4zl
      "" tags support, ';' means upward search, refering to http://vimdoc.sourceforge.net/htmldoc/editing.html#file-searching
      set tags=./tags;
      "" Fold
      """ fold text to be the first and last line
      """ refer to sbernheim4's reply at
      """ https://github.com/nvim-treesitter/nvim-treesitter/pull/390
      function! GetSpaces(foldLevel)
          if &expandtab == 1
              " Indenting with spaces
              let str = repeat(" ", a:foldLevel / (&shiftwidth + 1) - 1)
              return str
          elseif &expandtab == 0
              " Indenting with tabs
              return repeat(" ", indent(v:foldstart) - (indent(v:foldstart) / &shiftwidth))
          endif
      endfunction
      function! MyFoldText()
          let startLineText = getline(v:foldstart)
          let endLineText = trim(getline(v:foldend))
          let indentation = GetSpaces(foldlevel("."))
          let spaces = repeat(" ", 200)
          let str = indentation . startLineText . " …… " . endLineText . spaces
          return str
      endfunction
      "" toggle foldmethod between manual and indent
      set foldmethod=indent
      :function ToggleFoldmethod()
      : if (&foldmethod == "manual")
      :   set foldmethod=indent
      : else
      :   set foldmethod=manual
      : endif
      :endfunction
      nnoremap <Leader>z :call ToggleFoldmethod()<CR>:echo &foldmethod<CR>
      "" Custom display for text when folding
      set foldtext=MyFoldText()
      """ Set the foldlevel to a high setting,
      """ files are always loaded with opened folds.
      set foldlevel=20
      """ mouse support " select by pressing shift key!
      set mouse=a
      """ matchit.vim " :h matchit-install
      packadd! matchit
      "" Preview
      nnoremap <leader>[ :pc<CR>
      "" highlight unwanted whitespace
      set list
      set listchars=tab:>-,trail:-
      "" syntax
      syntax on
      "" backspace
      set backspace=indent,eol,start
      "" wrap line
      """ https://stackoverflow.com/questions/248102/is-there-any-command-to-toggle-enable-auto-text-wrapping
      :function ToggleWrap()
      : if (&wrap == 1)
      :   set nowrap
      : else
      :   set wrap
      : endif
      :endfunction
      nnoremap <F9> :call ToggleWrap()<CR>
      set updatetime=400
      "" highlight current line
      set cursorlineopt=number
      augroup CursorLine
        au!
        au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
        au WinLeave * setlocal nocursorline
      augroup END

      " filetype
      augroup filetype
          " detect LLVM IR file
          au! BufRead,BufNewFile *.ll     set filetype=llvm
          " cpp " from gem5
          au! BufRead,BufNewFile *.hh.inc,*.cc.inc set filetype=cpp
      augroup END

      " cscope
      " inspired by https://linux-kernel-labs.github.io/refs/heads/master/labs/introduction.html
      if has("cscope")
          " Look for a 'cscope.out' file starting from the current directory,
          " going up to the root directory.
          let s:dirs = split(getcwd(), "/")
          while s:dirs != []
              let s:path = "/" . join(s:dirs, "/")
              if (filereadable(s:path . "/cscope.out"))
                  execute "cs add " . s:path . "/cscope.out " . s:path . " -v"
                  break
              endif
              let s:dirs = s:dirs[:-2]
          endwhile

          set csto=0  " Use cscope first, then ctags
          set cst     " Only search cscope
          set csverb  " Make cs verbose

          " 0 symbol
          nmap <C-\>s :cs find s <C-R><C-W><CR>
          nmap <C-\>S :cs find s<Space>
          " 1 definition
          nmap <C-\>g :cs find g <C-R><C-W><CR>
          nmap <C-\>G :cs find g<Space>
          " 2 called func
          nmap <C-\>d :cs find d <C-R><C-W><CR>
          nmap <C-\>D :cs find d<Space>
          " 3 calling func
          nmap <C-\>c :cs find c <C-R><C-W><CR>
          nmap <C-\>C :cs find c<Space>
          " 4 text string
          nmap <C-\>t :cs find t <C-R><C-W><CR>
          nmap <C-\>T :cs find t<Space>
          " 6 egrep pattern
          nmap <C-\>e :cs find e <C-R><C-W><CR>
          nmap <C-\>E :cs find e<Space>
          " 7 file
          nmap <C-\>F :cs find f<Space>
          " 8 including file
          nmap <C-\>i :cs find i ^<C-R><C-F>$<CR>
          nmap <C-\>I :cs find i<Space>
          " 9 assign
          nmap <C-\>a :cs find a <C-R><C-W><CR>
          nmap <C-\>A :cs find a<Space>

          " Open a quickfix window for the following queries.
          "set cscopequickfix=s-,c-,d-,i-,t-,e-,g-
          "nmap <F6> :cnext <CR>
          "nmap <F5> :cprev <CR>
      endif

      " set terminal title
      "" https://stackoverflow.com/questions/15123477/tmux-tabs-with-name-of-file-open-in-vim
      autocmd BufEnter * let &titlestring = "" . expand("%:t")
      set title

      nnoremap <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
      \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
      \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

      " highlight
      augroup HiglightTODO
          autocmd!
          autocmd WinEnter,VimEnter * :silent! call matchadd('Todo', 'TODO', -1)
      augroup END

      " wildmenu
      " see: https://github.com/neovim/neovim/pull/11001
      cnoremap <expr> <Up>    pumvisible() ? "\<Left>"  : "\<Up>"
      cnoremap <expr> <Down>  pumvisible() ? "\<Right>" : "\<Down>"
      cnoremap <expr> <Left>  pumvisible() ? "\<Up>"    : "\<Left>"
      cnoremap <expr> <Right> pumvisible() ? "\<Down>"  : "\<Right>"
    '';
    plugins = with pkgs.vimPlugins; [
      vim-smoothie
      my-vim-mark
      vim-ingo-library
      vim-fugitive
      my-git-messenger-vim
      DrawIt
      vim-nix
      my-vim-floaterm
      vim-markdown-toc
      my-vista-vim
      vim-commentary
      my-nvim-treesitter
      # python lsp support:
      #   coc related info:
      #     https://github.com/neoclide/coc.nvim/wiki/Language-servers#python
      #       https://github.com/fannheyward/coc-pyright
      #   nixos vim related info:
      #     https://nixos.wiki/wiki/Vim
      #       https://github.com/NixOS/nixpkgs/issues/98166#issuecomment-725319238
      # coc-pyright
      # javascript lsp support
      # coc-tsserver
      my-vim-markdown # format table
      tabular
      my-vim-hexokinase
      vim-plugin-AnsiEsc
      my-nvim-config-local
      my-leap-nvim
      # {
      #   plugin = indentLine;
      #   config = ''
      #     " prevent conceal vim-markdown ```
      #     "" https://github.com/Yggdroot/indentLine
      #     "" Disabling conceal for JSON and Markdown without disabling indentLine plugin
      #     let g:vim_json_conceal = 0
      #     let g:vim_markdown_conceal = 0
      #   '';
      # }
      # telescope-nvim needs plenary-nvim and ripgrep
      my-telescope-nvim
      my-telescope-fzf-native-nvim
      plenary-nvim
      git-wip
      my-gitsigns-nvim
      my-color-scheme
      my-hbac
      my-winshift-nvim
    ] ++ (lib.optional config.isGui markdown-preview-nvim);
    vimdiffAlias = true;
    extraPackages = with pkgs; [
      ripgrep
    ];
  };
}
