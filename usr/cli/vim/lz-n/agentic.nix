# TODO: structured nix => lua, no abused mkLuaInline
{ pkgs, lib, ... }: {
  my.neovim.lz-n = [{
    plugin = pkgs.vimUtils.buildVimPlugin {
      pname = "agentic.nvim";
      version = "latest";
      src = pkgs.fetchFromGitHub {
        owner = "carlos-algms";
        repo = "agentic.nvim";
        rev = "5234e93013b86de0af54d9691b1781d9f2820e22";
        hash = "sha256-SF41b4GC03OHUs2Zdce13cPjrH01HBwKqaFntgPlvqE=";
      };
      postPatch = ''
        # disable headers as nvim already has displayed info in statusline
        sed -i '/^\s*set_winbar/d' lua/agentic/ui/window_decoration.lua
      '';
      doCheck = false;
    };
    spec = {
      after = lib.generators.mkLuaInline ''
        function() require("agentic").setup({
          acp_providers = {
            -- Add any new ACP-compatible provider — the name and command are up to you
            ["pi"] = {
              name = "pi",
              command = "pi-acp",
            },
          },
          provider = "pi",
          windows = {
            position = "left",
            width = 40,
          },
        }) end
      '';
      keys = lib.generators.mkLuaInline ''
        {
          {
            "<C-\\>",
            function() require("agentic").toggle() end,
            mode = { "n", "v", "i" },
            desc = "Toggle Agentic Chat"
          },
        }
      '';
    };
  }];
}
