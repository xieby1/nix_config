''
  redir /syncthing /syncthing/
  handle /syncthing/* {
    route {
      import auth
      uri strip_prefix /syncthing
      reverse_proxy 127.0.0.1:8384 {
        header_up Host {upstream_hostport}
      }
    }
  }
''
