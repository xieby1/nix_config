{ pkgs, ... }:
let
  # Pi injects @earendil-works/* and typebox at runtime, so drop its dev/peer
  # deps and their transitive graph from the install.
  slimSrc = pkgs.applyPatches {
    name = "pi-web-access-slim";
    src = pkgs.npinsed.ai.pi.pi-web-access;
    nativeBuildInputs = [ pkgs.jq ];
    postPatch = ''
      jq 'del(.devDependencies, .peerDependencies, .peerDependenciesMeta, .scripts)' package.json > package.json.tmp
      mv package.json.tmp package.json
      cp ${./package-lock.json} package-lock.json
    '';
  };
in {
  home.file.".pi/agent/extensions/pi-web-access".source = pkgs.buildNpmPackage {
    name = "pi-web-access";
    src = slimSrc;
    npmDepsHash = "sha256-aoS9mSkbGjjnhm7rwWoPBgK2XWJCmg0OmUMuuwAI/yc=";
    dontNpmBuild = true;
    npmRebuildFlags = [ "--ignore-scripts" ];
    nativeBuildInputs = [ pkgs.jq ];
    postInstall = ''
      # `bin` points at dist/mcp-cli.js, which only upstream's publish build
      # creates; drop the dead wrapper and the field that promises it.
      rm -rf $out/bin
      dir=$out/lib/node_modules/pi-web-access
      jq 'del(.bin)' "$dir/package.json" > "$dir/package.json.tmp"
      mv "$dir/package.json.tmp" "$dir/package.json"
      # Guard the one contract Pi needs: every declared entry file must exist.
      jq -r '.pi.extensions[]' "$dir/package.json" | while read -r e; do test -f "$dir/$e"; done
    '';
  } + /lib/node_modules/pi-web-access;
}
