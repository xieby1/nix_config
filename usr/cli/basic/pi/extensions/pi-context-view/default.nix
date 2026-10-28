{ pkgs, ... }:
let
  # Pi labels a local (non npm:/git:) extension in the startup banner after the
  # shortest unique tail of its entry path, with a trailing index.ts dropped.
  # Upstream declares ./src/index.ts, so the banner shows "src". Re-exporting
  # from a root index.ts makes the tail the package directory, "pi-context-view".
  src = pkgs.applyPatches {
    name = "pi-context-view";
    src = pkgs.npinsed.ai.pi.pi-context-view;
    postPatch = ''
      substituteInPlace package.json --replace-fail '"./src/index.ts"' '"./index.ts"'
      echo 'export { default } from "./src/index.ts";' > index.ts
    '';
  };
in
{
  # Raw TypeScript source, zero runtime dependencies: Pi injects the
  # @earendil-works/* peer packages at runtime, so there is no npm build step.
  # `/context config` writes ~/.pi/agent/extensions/pi-context-view.json, a
  # sibling of this directory, so it stays writable.
  home.file.".pi/agent/extensions/pi-context-view".source = src;
}
