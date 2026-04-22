{ pkgs, lib, ... }: {
  # The nixpkgs PR for kimi-cli has been stale for a long time.
  # It touches 8 files, making it impractical to add as a proper package.
  # Using home.activation provides a simple, pragmatic alternative.
  home.packages = [ pkgs.uv ];
  home.activation = {
    install-kimi = lib.hm.dag.entryAfter ["writeBoundary"] /*bash*/''
      if ! command -v kimi &> /dev/null; then
        run ${pkgs.uv}/bin/uv tool install -p ${pkgs.python3}/bin/python3 kimi-cli
      fi
    '';
  };
}
