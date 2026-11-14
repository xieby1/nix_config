''
  @xingyao path /BTeam/XingYao /BTeam/XingYao/*
  handle @xingyao {
    route {
      request_header -Remote-User
      request_header -Remote-Name
      request_header -Remote-Email
      request_header -Remote-Groups
      # Authorize the original resource path, before stripping the prefix.
      forward_auth 127.0.0.1:9091 {
        uri /api/authz/forward-auth
        copy_headers Remote-User Remote-Name Remote-Email
      }
      redir /BTeam/XingYao /BTeam/XingYao/ 308
      uri strip_prefix /BTeam/XingYao
      reverse_proxy 127.0.0.1:3004
    }
  }
''
