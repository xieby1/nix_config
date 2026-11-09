let
  pkgs = import <nixpkgs> {};
  sources = (import ../../../../../../npins) {input=../../sources.json;};
  inherit (pkgs) lib;
  evaluate = packages: (lib.evalModules {
    specialArgs.pkgs = packages;
    modules = [
      {
        options.home.file = lib.mkOption { type = lib.types.attrsOf lib.types.anything; default = {}; };
        options.home.packages = lib.mkOption { type = lib.types.listOf lib.types.package; default = []; };
        options.yq-merge = lib.mkOption { type = lib.types.attrsOf lib.types.anything; default = {}; };
      }
      ./default.nix
    ];
  }).config;
  cfg = evaluate pkgs;
  unsupported = evaluate (pkgs // { stdenv = pkgs.stdenv // { hostPlatform.system = "x86_64-darwin"; }; });
  imports = builtins.readFile ../default.nix;
in lib.runTests {
  test-installed-files = {
    expr = builtins.attrNames cfg.home.file;
    expected = [ ".pi/agent/extensions/pi-read-aloud" ".pi/models/tts/kokoro-multi-lang-v1_1" ];
  };
  test-auditioned-model-preserved = {
    expr = toString (cfg.home.file.".pi/models/tts/kokoro-multi-lang-v1_1".source or "missing");
    expected = toString (import ./model.nix { inherit pkgs; });
  };
  test-mpv-installed = { expr = cfg.home.packages; expected = [ pkgs.mpv-unwrapped ]; };
  test-no-global-settings-overrides = { expr = cfg.yq-merge; expected = {}; };
  test-unsupported-platform-stays-disabled = { expr = unsupported.home.file; expected = {}; };
  test-new-import = { expr = lib.hasInfix "./pi-read-aloud" imports; expected = true; };
  test-no-old-import = { expr = lib.hasInfix "./pi-voicekit" imports; expected = false; };
  test-no-old-upstream-pin = { expr = sources ? pi-voicekit; expected = false; };
}
