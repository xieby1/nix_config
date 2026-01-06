{ pkgs, ... }: let
  rustowl-pkgs = (pkgs.flake-compat {
    src = pkgs.fetchFromGitHub {
      owner = "nix-community";
      repo = "rustowl-flake";
      rev = "a84881d43ecd4914b6e2791f7777c6133f489bf9";
      hash = "sha256-ejraI1mCGebB98mH/cIR+GG1UwDTVnZojrHPLFErCxE=";
    };
  }).defaultNix.packages."${builtins.currentSystem}";
  rustowl = rustowl-pkgs.rustowl;
  rustowl-nvim = rustowl-pkgs.rustowl-nvim.overrideAttrs (old: {
    # This patch because:
    # The ftplugin/*.lua, is loaded before init.lua, see `:h init.lua`
    # As a result the user config does not work.
    # (It is this commit cause it: https://github.com/cordx56/rustowl/pull/48)
    # So we move ftplugin/rust.lua to lua/rustowl/autosetup.lua,
    # and call require("rustowl/autosetup") after require("rustowl").setup
    postPatch = ''
      mv ftplugin/rust.lua lua/rustowl/autosetup.lua
    '';
  });
in {
  programs.neovim = {
    plugins = [{
      plugin = rustowl-nvim;
      type = "lua";
      config = /*lua*/ ''
        require("rustowl").setup({
          auto_enable = true,
          highlight_style = 'underline',
          -- drawio preset border colors
          colors = {
            lifetime = '#82B366',
            imm_borrow = '#6C8EBF',
            mut_borrow = '#9673A6',
            move = '#D79B00',
            call = '#D6B656',
            outlive = '#B85450',
          },
        })
        vim.api.nvim_create_autocmd("FileType", {
          pattern = {"rust"},
          callback = function() require("rustowl.autosetup") end
        })
      '';
    }];
    extraPackages = [ rustowl ];
  };

  cachix_packages = [ rustowl rustowl-nvim ];

  # Set the rustowl toolchain, which is a nightly toolchain.
  home.file.rustowl_sysroot = {
    source = rustowl.RUSTOWL_SYSROOTS;
    target = ".rustowl/sysroot/${rustowl.RUSTUP_TOOLCHAIN}";
  };
}
