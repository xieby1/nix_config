let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) lib;
  hm = import <home-manager/modules> {
    inherit pkgs;
    configuration = {
      imports = [ ../. ../../../modules/yq-merge ];
      home = { stateVersion = "25.11"; username = "dummy"; homeDirectory = "/dummy"; };
    };
  };
  cfg = hm.config;
  vinput = builtins.filter (p: lib.getName p == "fcitx5-vinput") cfg.i18n.inputMethod.fcitx5.addons;
  daemon = cfg.systemd.user.services.vinput-daemon or {};
in lib.runTests {
  test-addon = {
    expr = builtins.length vinput;
    expected = 1;
  };
  test-cli-and-gui-package = {
    expr = vinput != [] && builtins.elem (builtins.head vinput) cfg.home.packages;
    expected = true;
  };
  test-daemon = {
    expr = {
      type = daemon.Service.Type or null;
      bus = daemon.Service.BusName or null;
      after = daemon.Unit.After or [];
      wantedBy = daemon.Install.WantedBy or [];
    };
    expected = {
      type = "dbus";
      bus = "org.fcitx.Vinput";
      after = [ "pipewire.service" ];
      wantedBy = [ "default.target" ];
    };
  };
  test-daemon-executable = {
    expr = vinput != [] && (daemon.Service.ExecStart or []) == [ "${builtins.head vinput}/bin/vinput-daemon" ];
    expected = true;
  };
  test-unsupported-system = let
    unsupported = import <home-manager/modules> {
      pkgs = import <nixpkgs> { system = "riscv64-linux"; };
      configuration = {
        imports = [ ./. ];
        home = { stateVersion = "25.11"; username = "dummy"; homeDirectory = "/dummy"; };
      };
    };
  in {
    expr = {
      addons = unsupported.config.i18n.inputMethod.fcitx5.addons;
      daemon = unsupported.config.systemd.user.services ? vinput-daemon;
    };
    expected = { addons = []; daemon = false; };
  };
  test-existing-addons = {
    expr = lib.all (p: builtins.elem p cfg.i18n.inputMethod.fcitx5.addons) [
      pkgs.qt6Packages.fcitx5-chinese-addons pkgs.fcitx5-pinyin-zhwiki
      pkgs.fcitx5-mozc-ut pkgs.fcitx5-hangul
    ];
    expected = true;
  };
}
