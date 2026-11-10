let
  pkgs = import <nixpkgs> {};
  sources = (import ../../../../../npins) {input=../sources.json;};
  module = import ./default.nix {src = sources.pi-web;} {
    inherit pkgs;
    lib = import <home-manager/modules/lib/stdlib-extended.nix> pkgs.lib;
    config.home.homeDirectory = "/home/test";
  };
  cleanup = pkgs.writeText "disable-session-naming-test.sh"
    (pkgs.lib.replaceStrings [ "/home/test" ] [ "$TMPDIR/home" ]
      module.home.activation.disablePiWebSessionNaming.data);
  cleanedSettings = pkgs.runCommand "clean-session-naming-settings" {} ''
    mkdir -p "$TMPDIR/home/.pi/agent"
    cat > "$TMPDIR/home/.pi/agent/settings.json" <<'JSON'
    {"packages":["/nix/store/old/lib/node_modules/pi-web/dist/pi-packages/session-naming","npm:@jmfederico/pi-session-naming@1",{"source":"npm:@jmfederico/pi-session-naming"},"npm:keep",{"source":"npm:keep-object"}],"keep":true}
    JSON
    run() { "$@"; }
    source ${cleanup}
    source ${cleanup}
    cp "$TMPDIR/home/.pi/agent/settings.json" "$out"
  '';
in pkgs.lib.debug.throwTestFailures { failures = pkgs.lib.runTests {
  test-remove-installed-session-naming = {
    expr = builtins.fromJSON (builtins.readFile cleanedSettings);
    expected = { packages = [ "npm:keep" { source = "npm:keep-object"; } ]; keep = true; };
  };
  test-session-naming-dismissed = {
    expr = map (entry: entry.packageId) (builtins.fromJSON
      module.home.file.".local/state/pi-web/pi-package-dismissals.json".text).dismissals;
    expected = [ "@jmfederico/pi-session-naming" "@jmfederico/pi-relay" "@jmfederico/pi-web-workflows" ];
  };
}; }
