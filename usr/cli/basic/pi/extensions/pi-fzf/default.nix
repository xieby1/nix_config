{ pkgs, ... }:
let
  # Only runtime dep is the `fzf` JS matching library; pi 1.4 aliases the
  # @mariozechner/* peers to its bundled modules, so they are stripped here.
  slimSrc = pkgs.applyPatches {
    name = "pi-fzf-slim";
    src = pkgs.npinsed.ai.pi.pi-fzf;
    nativeBuildInputs = [ pkgs.jq ];
    postPatch = ''
      jq 'del(.peerDependencies, .devDependencies, .scripts)' package.json > package.json.tmp
      mv package.json.tmp package.json
      cp ${./package-lock.json} package-lock.json
    '';
  };
in {
  home.file.".pi/agent/extensions/pi-fzf".source = pkgs.buildNpmPackage {
    name = "pi-fzf";
    src = slimSrc;
    npmDepsHash = "sha256-A4Lk2SFuzHoS5K9mjCkd6xl3nk2CFoKD8vn1R2ToEL4=";
    dontNpmBuild = true;
  } + "/lib/node_modules/pi-fzf";

  # pi-fzf registers nothing without a config, and the builtin @ picker stops at
  # a fixed depth, so register a whole-tree picker as `/fzf:file`.
  yq-merge.".pi/agent/fzf.json" = {
    generator = builtins.toJSON;
    expr = {
      commands.file = {
        list = "rg --files --hidden";
        action = {
          type = "editor";
          template = "@\"{{selected}}\"";
        };
        # Clear the shell preview from previously merged configs.
        preview = null;
      };
    };
  };
}
