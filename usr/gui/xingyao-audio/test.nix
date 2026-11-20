let
  pkgs = import <nixpkgs> {};
  hm = import <home-manager/modules> {
    inherit pkgs;
    configuration = {
      imports = [ ./. ];
      home = { stateVersion = "25.11"; username = "dummy"; homeDirectory = "/dummy"; };
    };
  };
  cfg = hm.config;
  file = cfg.xdg.configFile."wireplumber/wireplumber.conf.d/51-xingyao-audio.conf" or null;
  service = cfg.systemd.user.services.xingyao-audio or {};
in pkgs.lib.debug.throwTestFailures { failures = pkgs.lib.runTests (pkgs.lib.optionalAttrs
  (pkgs.lib.trim (builtins.readFile /etc/hostname) == "techrevo") {
  test-card-rule = {
    expr = if file == null then null else
      builtins.head (builtins.fromJSON file.text)."monitor.alsa.rules";
    expected = {
      matches = [{ "device.name" = "alsa_card.pci-0000_c1_00.6"; }];
      actions.update-props."api.alsa.use-acp" = false;
    };
  };
  test-speaker-stereo-rule = {
    expr = if file == null then [] else builtins.filter
      (rule: rule.matches == [{ "node.name" = "alsa_output.pci-0000_c1_00.6.playback.0.0"; }])
      (builtins.fromJSON file.text)."monitor.alsa.rules";
    expected = [{
      matches = [{ "node.name" = "alsa_output.pci-0000_c1_00.6.playback.0.0"; }];
      actions.update-props = {
        "audio.channels" = 2;
        "audio.position" = [ "FL" "FR" ];
      };
    }];
  };
  test-restart-with-wireplumber = {
    expr = {
      after = service.Unit.After or [];
      partOf = service.Unit.PartOf or [];
      wantedBy = service.Install.WantedBy or [];
      remain = service.Service.RemainAfterExit or false;
    };
    expected = {
      after = [ "wireplumber.service" ];
      partOf = [ "wireplumber.service" ];
      wantedBy = [ "wireplumber.service" ];
      remain = true;
    };
  };
}); }
