{ pkgs, ... }:
{
  home.file.".pi/agent/extensions/pi-model-project".source =
    pkgs.runCommand "pi-model-project" { nativeBuildInputs = [ pkgs.nodejs ]; } ''
      mkdir -p extension/node_modules/@earendil-works
      cp ${./index.ts} extension/index.ts
      cp ${./test.mjs} extension/test.mjs
      ln -s ${pkgs.pkgsu.pi-coding-agent}/lib/node_modules/pi-monorepo \
        extension/node_modules/@earendil-works/pi-coding-agent
      node --test extension/test.mjs
      mkdir -p "$out"
      cp extension/index.ts "$out/index.ts"
    '';
}
