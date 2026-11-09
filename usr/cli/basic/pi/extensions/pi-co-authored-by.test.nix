let
  pkgs = import <nixpkgs> {};
  sources = (import ../../../../../npins) {input=../sources.json;};
  module = import ./pi-co-authored-by.nix {src = sources.shelken-pi-extensions;} { inherit pkgs; };
  root = module.home.file.".pi/agent/extensions/pi-co-authored-by".source;
  manifest = builtins.fromJSON (builtins.readFile "${root}/package.json");
  original = builtins.fromJSON (builtins.readFile
    "${sources.shelken-pi-extensions}/extensions/pi-co-authored-by/package.json");
in pkgs.lib.runTests {
  test-coauthor-manifest = {
    expr = manifest;
    expected = original // { pi = original.pi // { extensions = [ "./index.ts" ]; }; };
  };
  test-coauthor-reexport = {
    expr = if builtins.pathExists "${root}/index.ts"
      then builtins.readFile "${root}/index.ts" else null;
    expected = "export { default } from \"./src/index.ts\";\n";
  };
}
