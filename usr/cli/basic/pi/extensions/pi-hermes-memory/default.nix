{ config, pkgs, lib, ... }: let
  # The node-gyp should be backed by the same version of nodejs as pi,
  # thus we use pkgspi.
  pkgspi = pkgs.pkgsu;
  # Pi supplies @earendil-works/* at runtime; dropping devDependencies and
  # peerDependencies also removes the nested lock entries whose missing
  # integrity used to require lock-integrity.patch.
  slimSrc = pkgs.applyPatches {
    name = "pi-hermes-memory-slim";
    src = pkgs.npinsed.ai.pi.pi-hermes-memory;
    nativeBuildInputs = [ pkgs.jq ];
    postPatch = ''
      jq 'del(.devDependencies, .peerDependencies, .scripts)' package.json > package.json.tmp && mv package.json.tmp package.json
      cp ${./package-lock.json} package-lock.json
    '';
  };
in {
  home.file.".pi/agent/extensions/pi-hermes-memory" = {
    source = pkgspi.buildNpmPackage {
      name = "pi-hermes-memory";
      src = slimSrc;
      npmDepsFetcherVersion = 2;
      npmDepsHash = "sha256-iA9TQ21f3UcJoR3LGu6v8DR5VpSQFCXUXXyvkQpAkEc=";
      dontNpmBuild = true;
      # Pi uses the first path segment of pi.extensions entry as the banner
      # display name. Upstream uses "./src/index.ts" which shows as "src".
      # Move the entrypoint to "./index.ts" so it falls back to package name.
      postInstall = ''
        cd $out/lib/node_modules/pi-hermes-memory
        sed -i 's|"./src/index.ts"|"./index.ts"|' package.json
        echo 'export { default } from "./src/index.ts";' > index.ts
      '';
      nativeBuildInputs = with pkgspi; [
        node-gyp
        python3
      ];
    } + /lib/node_modules/pi-hermes-memory;
  };
  home.file.".pi/agent/projects-memory".source = config.lib.file.mkOutOfStoreSymlink ~/Gist/Data/pi/projects-memory;

  # pi-hermes-memory writes MEMORY.md/USER.md via temp-file + rename, which would
  # replace per-file symlinks. Symlink the whole writable directory instead.
  home.file.".pi/agent/pi-hermes-memory".source = config.lib.file.mkOutOfStoreSymlink ~/Gist/Data/pi/pi-hermes-memory;
  my.syncthing.Gist-stignore = lib.mkAfter [
    "/Data/pi/pi-hermes-memory/sessions.db"
    "/Data/pi/pi-hermes-memory/sessions.db-*"
  ];
}
