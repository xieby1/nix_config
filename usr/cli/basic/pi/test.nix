let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;
  evaluate = enableExtendedCLI: (import <home-manager/modules> {
    inherit pkgs;
    configuration = {
      imports = [
        ../../../modules
        ../../../yq-merge
        ../../../syncthing-gist-ignore.nix
        (lib.modules.importApply ./. {inherit enableExtendedCLI;})
      ];
      home.username = "test";
      home.homeDirectory = "/home/test";
      home.stateVersion = "25.05";
    };
  }).config;
  basic = evaluate false;
  extended = evaluate true;
  extensionSources = cfg: lib.mapAttrs (_: file: toString file.source)
    (lib.filterAttrs (name: _: lib.hasPrefix ".pi/agent/extensions/" name) cfg.home.file);
  piPackage = cfg: lib.findFirst (p: lib.getName p == "pi-coding-agent")
    (throw "Pi package missing") cfg.home.packages;
in lib.runTests {
  test-no-global-pi-pins = { expr = pkgs.npinsed ? ai.pi; expected = false; };
  test-no-global-pi-package-set = { expr = pkgs ? pipkgs; expected = false; };
  test-core-package-shared-between-profiles = {
    expr = (piPackage basic).drvPath;
    expected = (piPackage extended).drvPath;
  };
  test-explicit-sources-shared-between-profiles = {
    expr = extensionSources basic;
    expected = builtins.removeAttrs (extensionSources extended) [ ".pi/agent/extensions/pi-read-aloud" ];
  };
  test-basic-excludes-extended-features = {
    expr = {
      web = builtins.attrNames basic.systemd.user.services;
      readAloud = basic.home.file ? ".pi/agent/extensions/pi-read-aloud";
    };
    expected = { web = []; readAloud = false; };
  };
  test-extended-keeps-web-and-read-aloud = {
    expr = {
      web = builtins.attrNames extended.systemd.user.services;
      readAloud = extended.home.file ? ".pi/agent/extensions/pi-read-aloud";
    };
    expected = { web = [ "pi-web-sessiond" "pi-web-web" ]; readAloud = true; };
  };
}
