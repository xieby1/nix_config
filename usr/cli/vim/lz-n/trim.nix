{ pkgs, lib, ... }: {
  my.neovim.lz-n = [{
    plugin = pkgs.vimPlugins.trim-nvim;
    spec = {
      # Only "Trim" (not "TrimToggle") triggers lazy-loading of trim.nvim.
      # Behavior:
      # - Before ":Trim" is called, trim.nvim is not loaded, so writes won't auto-trim.
      # - After ":Trim" is called, trim.nvim is loaded and enabled (default behavior).
      #   Subsequent writes will also trigger trimming.
      #   To disable temporarily, call `:TrimToggle` (available once trim.nvim is loaded).
      cmd = ["Trim"];
      after = lib.generators.mkLuaInline /*lua*/ ''
        function() require("trim").setup({}) end
      '';
    };
  }];
}
