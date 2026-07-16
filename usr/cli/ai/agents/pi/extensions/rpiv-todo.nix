{ pkgs, lib, ... }: {
  home.file.".pi/agent/extensions/rpiv-todo" = {
    source = pkgs.buildNpmPackage {
      name = "rpiv-todo";
      src = pkgs.applyPatches {
        name = "rpiv-mono-slim";
        src = pkgs.npinsed.ai.pi.rpiv-mono;
        # Trim monorepo to only rpiv-todo's workspace deps so npm fetches less.
        # Strip devDeps from root and peerDeps from workspace packages — Pi
        # provides @earendil-works/* at runtime.
        postPatch = ''
          ${lib.getExe pkgs.jq} '
            .workspaces = ["packages/rpiv-todo", "packages/rpiv-config", "packages/rpiv-i18n"]
            | .devDependencies = {}
            | del(.scripts.prepare)
          ' package.json > package.json.tmp && mv package.json.tmp package.json
          for p in packages/rpiv-{todo,config,i18n}; do
            ${lib.getExe pkgs.jq} 'del(.peerDependencies, .devDependencies)' \
              "$p/package.json" > "$p/package.json.tmp" && mv "$p/package.json.tmp" "$p/package.json"
          done
          cp ${./rpiv-todo-lockfile.json} package-lock.json
        '';
      };
      npmDepsHash = "sha256-WM82ZnPyKsmm7Y/QpmqbjIhq8DRyQgWIlkMQOUF+Jac=";
      forceEmptyCache = true;
      dontNpmBuild = true;
    } + /lib/node_modules/rpiv-mono/packages/rpiv-todo;
  };
}
