{ pkgs, ... }: {
  programs.neovim = {
    plugins = [(
      pkgs.vimPlugins.venn-nvim.overrideAttrs (old: {
        # ▲ ▼ ◀ ▶
        postPatch = ''
          sed -i 's/►/▶/' lua/venn/init.lua
          sed -i 's/◄/◀/' lua/venn/init.lua
          sed -i 's/►/▶/' src/primitives/box.lua.t
          sed -i 's/◄/◀/' src/primitives/box.lua.t
        '';
      })
    )];
  };
}
