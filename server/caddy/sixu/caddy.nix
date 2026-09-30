''
  redir /sixu/xby /sixu/xby/
  redir /sixu/wxy /sixu/wxy/
  handle /sixu/xby/* {
    route {
      import auth
      uri strip_prefix /sixu/xby
      reverse_proxy 127.0.0.1:3000
    }
  }
  handle /sixu/wxy/* {
    route {
      import auth
      uri strip_prefix /sixu/wxy
      reverse_proxy 127.0.0.1:3001
    }
  }
''
