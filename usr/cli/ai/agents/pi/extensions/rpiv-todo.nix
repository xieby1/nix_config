{ pkgs, ... }: {
  home.file.".pi/agent/extensions/rpiv-todo" = {
    source = pkgs.buildNpmPackage {
      name = "rpiv-todo";
      src = pkgs.npinsed.ai.pi.rpiv-mono;
      npmDepsHash = "sha256-ycMGGtKv6/aIgPfl+xnhNe1V2pcu8F/i0JZJfGRHT2s=";
      dontNpmBuild = true;
    } + /lib/node_modules/rpiv-mono/packages/rpiv-todo;
  };
}
