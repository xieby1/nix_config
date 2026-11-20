{ src }: # local-args
{ pkgs, lib, ... }:
let
  # Pi injects @earendil-works/* and typebox at runtime; only proper-lockfile
  # is a real dependency, so the trimmed lockfile installs nothing else.
  slimSrc = pkgs.applyPatches {
    name = "pi-model-fallback-slim";
    inherit src;
    nativeBuildInputs = [ pkgs.jq ];
    postPatch = ''
      jq 'del(.devDependencies, .peerDependencies, .peerDependenciesMeta, .scripts)' package.json > package.json.tmp
      mv package.json.tmp package.json
      cp ${./package-lock.json} package-lock.json
    '';
  };
in {
  # config.json and state.json live in Pi's agent dir (a sibling of this
  # extension), so `/model-fallback:*` keeps writing there.
  home.file.".pi/agent/extensions/pi-model-fallback".source = pkgs.buildNpmPackage {
    pname = "pi-model-fallback";
    version = "0.6.2";
    src = slimSrc;
    npmDepsHash = "sha256-8XXxcYSeq6rPOdL0BNW8lJFfM7Kco87pqNz4C6gKNaM=";
    dontNpmBuild = true;
  } + "/lib/node_modules/pi-model-fallback";

  # yq-merge deep-merges into the live file, so key and rule *deletions* here do
  # nothing and number arrays union. After removing a key or narrowing
  # `statuses`, delete ~/.pi/agent/model-fallback/config.json and switch again.
  # `version` is required by validateConfigShape: without it the extension only
  # warns "config error" and stays inert.
  yq-merge.".pi/agent/model-fallback/config.json" = {
    generator = builtins.toJSON;
    expr = {
      version = 1;
      rules = [
        {
          name = "kimi-unavailable";
          matchProviders = [ "jw2-kimi" ];
          statuses = [ 503 ];
          fallback = { provider = "jw2-deepseek"; model = "deepseek-flash"; };
        }
      ];
    };
  };
}
