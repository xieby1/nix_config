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
      doCheck = false;
    };
    spec = {
      after = lib.generators.mkLuaInline ''
        function() require("agentic").setup({
          provider = "copilot-acp",
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
