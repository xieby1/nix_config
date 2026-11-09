let
  pkgs = import <nixpkgs> {};
  sources = (import ../../../../../npins) {input=../sources.json;};
  module = import ./default.nix {src = sources.pi-web;} {
    inherit pkgs;
    inherit (pkgs) lib;
    config.home.homeDirectory = "/home/test";
  };
  package = builtins.head module.home.packages;
  root = "${package}/lib/node_modules/pi-web/dist/pi-packages/session-naming";
  manifest = builtins.fromJSON (builtins.readFile "${root}/package.json");
in pkgs.lib.runTests {
  test-session-naming-entrypoint = {
    expr = manifest.pi.extensions;
    expected = [ "./index.js" ];
  };
  test-session-naming-reexport = {
    expr = if builtins.pathExists "${root}/index.js"
      then builtins.readFile "${root}/index.js" else null;
    expected = "export { default } from \"./extensions/index.js\";\n";
  };
}
