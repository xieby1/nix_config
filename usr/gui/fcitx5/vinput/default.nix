{ pkgs, lib, ... }: let
  system = pkgs.stdenv.hostPlatform.system;
  vinput = (pkgs.flake-compat {
    src = pkgs.npinsed.de.fcitx5-vinput;
  }).defaultNix.packages.${system}.default;
in lib.mkIf (builtins.elem system [ "x86_64-linux" "aarch64-linux" ]) {
  home.packages = [ vinput ];
  i18n.inputMethod.fcitx5.addons = [ vinput ];

  # Keep downloaded models and runtime settings writable by Vinput.
  systemd.user.services.vinput-daemon = {
    Unit = {
      Description = "Vinput Voice Input Daemon";
      After = [ "pipewire.service" ];
    };
    Service = {
      Type = "dbus";
      BusName = "org.fcitx.Vinput";
      ExecStart = "${vinput}/bin/vinput-daemon";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
