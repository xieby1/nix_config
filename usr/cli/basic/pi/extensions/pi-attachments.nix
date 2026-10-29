{ pkgs, ... }:
let
  # Pi labels a local extension in the startup banner after the shortest unique
  # tail of its entry path. Upstream declares ./extensions/index.ts, so the
  # banner would show "extensions"; re-export from a root index.ts instead.
  src = pkgs.applyPatches {
    name = "pi-attachments";
    src = pkgs.npinsed.ai.pi.pi-extensions + "/pi-attachments";
    postPatch = ''
      substituteInPlace package.json --replace-fail '"./extensions/index.ts"' '"./index.ts"'
      echo 'export { default } from "./extensions/index.ts";' > index.ts
    '';
  };
in
{
  # Raw TypeScript source, zero runtime dependencies: Pi injects the
  # @earendil-works/* peers at runtime, so there is no npm build step.
  home.file.".pi/agent/extensions/pi-attachments".source = src;
}
