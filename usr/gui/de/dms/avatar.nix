{ pkgs, ... }: {
  xdg.cacheFile."dms-avatar.png" = {
    source = pkgs.fetchurl {
      url = "https://github.com/xieby1.png";
      sha256 = "1s20qy3205ljp29lk0wqs6aw5z67db3c0lvnp0p7v1q2bz97s9bm";
    };
    # DMS currently has no config option for the avatar path, so set it through IPC.
    onChange = ''
      PATH="$PATH:${pkgs.quickshell}/bin" ${pkgs.dms-shell}/bin/dms ipc call profile setImage ~/.cache/dms-avatar.png
    '';
  };
}
