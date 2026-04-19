{ pkgs, ... }: {
  programs.dank-material-shell.plugins = {
    dms-unified-taskbar.src = pkgs.applyPatches {
      name = "dms-unified-taskbar-patched";
      src = pkgs.npinsed.de.dms-unified-taskbar;
      patches = [./remove-DankRipple.patch];
    };
  };
}
