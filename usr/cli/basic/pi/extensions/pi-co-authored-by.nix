{ src }: # local-args
{ pkgs, ... }: {
  home.file.".pi/agent/extensions/pi-co-authored-by".source = pkgs.applyPatches {
    name = "pi-co-authored-by";
    src = src.outPath + "/extensions/pi-co-authored-by";
    # A root entrypoint makes Pi's compact banner show pi-co-authored-by, not src.
    postPatch = ''
      ${pkgs.jq}/bin/jq '.pi.extensions = ["./index.ts"]' package.json > package.json.new
      mv package.json.new package.json
      echo 'export { default } from "./src/index.ts";' > index.ts
    '';
  };
}
