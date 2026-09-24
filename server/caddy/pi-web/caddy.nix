# dell's pi-web (jmfederico) over the tailnet via the socat bridge (./config.nix).
# pi-web is prefix-portable, so only this sub-path needs routing; it keeps its
# browser/PWA/WS URLs under /pi/dell/ itself.
let
  consts = import ./consts.nix;
in ''
  redir /pi/dell /pi/dell/
  handle /pi/dell/* {
    route {
      import auth
      uri strip_prefix /pi/dell
      reverse_proxy 127.0.0.1:${toString consts.bridgePort}
    }
  }
''
