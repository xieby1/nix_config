{ lib, ... }: {
  imports = [
    ./authelia
    ./caddy
    (lib.modules.importApply ./circle {
      src = (import <npins> {input=./circle/sources.json;}).circle;
    })
    (lib.modules.importApply ./sixu {
      src = (import <npins> {input=./sixu/sources.json;}).sixu;
    })
    (lib.modules.importApply ./xingyao {
      src = (import <npins> {input=./xingyao/sources.json;}).xingyao;
    })
  ];

  options.my.server.caddyAuthelia.enable = lib.mkEnableOption "Caddy + Authelia prototype user services";

  config = {
    targets.genericLinux.enable = true;
    targets.genericLinux.gpu.enable = false;

    # NOTE: These server daemons run as root Home Manager user services. The host
    # must keep root's systemd user manager alive after logout:
    #
    #   loginctl enable-linger root
    #
    # Without lingering, the last root SSH logout stops user@0.service, which
    # stops Caddy/Authelia and browsers may report PR_END_OF_FILE_ERROR.
    my.server.caddyAuthelia.enable = true;
  };
}
