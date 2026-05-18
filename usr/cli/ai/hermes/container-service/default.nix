{ pkgs, config, lib, ... }: {
  options.my.hermes-container.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable hermes-container service by `my.hermes-container.enable = true`";
  };
  config = lib.mkIf config.my.hermes-container.enable {
    systemd.user.services.hermes-container = {
      Unit = {
        After = ["network.target"];
      };
      Install = {
        WantedBy = ["default.target"];
      };
      Service = {
        ExecStart = import ./container.nix;
        # TODO: graceful exit, the following command will send SIGKILL in 30 secs
        ExecStop = "${pkgs.podman}/bin/podman stop --time 30 hermes-container";
      };
    };
  };
}
