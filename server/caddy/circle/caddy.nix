''
  redir /circle/xby /circle/xby/
  redir /circle/wxy /circle/wxy/
  handle /circle/xby/* {
    route {
      import auth
      uri strip_prefix /circle/xby
      reverse_proxy 127.0.0.1:3002
    }
  }
  handle /circle/wxy/* {
    route {
      import auth
      uri strip_prefix /circle/wxy
      reverse_proxy 127.0.0.1:3003
    }
  }
''
