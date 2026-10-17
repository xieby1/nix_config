# Caddy route fragment for cgit, included by ../default.nix.
#
# Serves <prefix>/… : browsing via cgit.cgi and smart clones via
# git-http-backend, both over FastCGI to the loopback fcgiwrap started in
# ./config.nix. cgit speaks plain CGI (env in, stdout out), which Caddy cannot
# run; the fcgiwrap hop is what lets Caddy serve it at all.
{ cgit, git, cgitrc, reposPath }:
let
  consts = import ./consts.nix;
  prefix = consts.prefix;
  upstream = "127.0.0.1:${toString consts.fcgiwrapPort}";
in ''
  redir ${prefix} ${prefix}/

  # cgit's static assets; the URLs come from css=/favicon=/… in cgitrc.
  @cgit_assets path ${prefix}/cgit.css ${prefix}/cgit.js ${prefix}/cgit.png ${prefix}/favicon.ico ${prefix}/robots.txt
  handle @cgit_assets {
    route {
      import auth
      uri strip_prefix ${prefix}
      root * ${cgit}/cgit
      file_server
    }
  }

  # "git clone https://…${prefix}/<repo>.git": smart HTTP, served by git itself,
  # not cgit. PATH_INFO becomes the repo path relative to GIT_PROJECT_ROOT.
  @cgit_clone path ${prefix}/*/info/refs ${prefix}/*/git-upload-pack
  handle @cgit_clone {
    route {
      import auth
      uri strip_prefix ${prefix}
      reverse_proxy ${upstream} {
        transport fastcgi {
          env SCRIPT_FILENAME ${git}/libexec/git-core/git-http-backend
          env GIT_PROJECT_ROOT ${reposPath}
          env GIT_HTTP_EXPORT_ALL 1
          env PATH_INFO {http.request.uri.path}
        }
      }
    }
  }

  # Browsing. cgitrc sets virtual-root=${prefix}/, so links look like
  # ${prefix}/<repo>/… and the stripped remainder becomes PATH_INFO.
  handle ${prefix}/* {
    route {
      import auth
      uri strip_prefix ${prefix}
      reverse_proxy ${upstream} {
        transport fastcgi {
          env SCRIPT_FILENAME ${cgit}/cgit/cgit.cgi
          env CGIT_CONFIG ${cgitrc}
          env SCRIPT_NAME ${prefix}
          env PATH_INFO {http.request.uri.path}
        }
      }
    }
  }
''
