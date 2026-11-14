let
  pkgs = import <nixpkgs> {};
  evaluate = hostName: (import <nixpkgs/nixos/lib/eval-config.nix> {
    inherit pkgs;
    modules = [ ../default.nix {
      networking.hostName = hostName;
      system.stateVersion = "25.11";
    } ];
  }).config;
  cfg = evaluate "techrevo";
  audioState = c: {
    workaround = c.systemd.services.xingyao-speakers.enable;
    resumeWorkaround = pkgs.lib.hasInfix "systemctl restart xingyao-speakers.service"
      c.powerManagement.resumeCommands;
    patch = builtins.any (p: p.name == "alc256-xingyao-speakers") c.boot.kernelPatches;
  };
in pkgs.lib.debug.throwTestFailures { failures = pkgs.lib.runTests {
  test-driver-by-default = {
    expr = audioState cfg;
    expected = { workaround = false; resumeWorkaround = false; patch = true; };
  };
  test-workaround-fallback = {
    expr = if cfg.specialisation ? xingyao-speakers-workaround
      then audioState cfg.specialisation.xingyao-speakers-workaround.configuration
      else null;
    expected = { workaround = true; resumeWorkaround = true; patch = false; };
  };
  test-disabled-on-other-hosts = {
    expr = let other = evaluate "another-host"; in {
      service = other.systemd.services ? xingyao-speakers;
      fallback = other.specialisation ? xingyao-speakers-workaround;
      patch = builtins.any (p: p.name == "alc256-xingyao-speakers") other.boot.kernelPatches;
    };
    expected = { service = false; fallback = false; patch = false; };
  };
  test-fallback-boot-and-stop = {
    expr = let service = cfg.systemd.services.xingyao-speakers; in {
      wantedBy = service.wantedBy;
      after = service.after;
      type = service.serviceConfig.Type;
      remain = service.serviceConfig.RemainAfterExit;
      canRestore = service.serviceConfig ? ExecStop;
    };
    expected = {
      wantedBy = [ "multi-user.target" ];
      after = [ "sound.target" "alsa-restore.service" ];
      type = "oneshot";
      remain = true;
      canRestore = true;
    };
  };
}; }
