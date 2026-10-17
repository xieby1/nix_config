# Caddy route fragment for cgit, included by ../default.nix.
#
# Serves <prefix>/… : browsing via cgit.cgi and smart clones via
# git-http-backend, both over FastCGI to the loopback fcgiwrap started in
# ./config.nix. cgit speaks plain CGI (env in, stdout out), which Caddy cannot
# run; the fcgiwrap hop is what lets Caddy serve it at all.
#
# Access control lives entirely in Authelia (see ../../authelia/default.nix):
# guests of a team are allowed only <prefix>/<team>/…, which is why the repo
# name must come from the path alone — hence the ?url= refusal below.
{ cgit, git, cgitrc, reposPath }:
let
  consts = import ./consts.nix;
  prefix = consts.prefix;
  upstream = "127.0.0.1:${toString consts.fcgiwrapPort}";
in ''
  redir ${prefix} ${prefix}/

  # cgit's static assets; the URLs come from css=/favicon=/… in cgitrc. No auth
  # here: they are plain files from the cgit package.
  @cgit_assets path ${prefix}/cgit.css ${prefix}/cgit.js ${prefix}/cgit.png ${prefix}/favicon.ico ${prefix}/robots.txt
  handle @cgit_assets {
    route {
      uri strip_prefix ${prefix}
      root * ${cgit}/cgit
      file_server
    }
  }

  handle ${prefix}/* {
    route {
      import auth

      # cgit takes the repo from ?url= in preference to PATH_INFO, so any
      # allowed path could render any repo (/repos/BTeam/x/?url=/Other.git).
      # Authelia only sees the path, so refuse the parameter here. Applies to the
      # owner too; cgit emits no such links when virtual-root is set.
      # shortcut: blocklist of one parameter; re-check on cgit upgrades.
      @repo_override query url=*
      respond @repo_override 403

      uri strip_prefix ${prefix}

      # Clones and browsing share this route: only a regexp matches repos
      # nested at any depth (…/BTeam/x.git/info/refs), and Caddy sorts
      # regexp-only `handle` blocks after path ones, so a separate clone
      # handler would be shadowed by the browsing handler. Anchored on .git so
      # a cgit file view ending in info/refs (…/x.git/plain/info/refs) is not
      # mistaken for a clone; every repo here is a …​.git directory.
      @clone path_regexp \.git/(info/refs|git-upload-pack)$
      reverse_proxy @clone ${upstream} {
        transport fastcgi {
          env SCRIPT_FILENAME ${git}/libexec/git-core/git-http-backend
          env GIT_PROJECT_ROOT ${reposPath}
          env GIT_HTTP_EXPORT_ALL 1
          env PATH_INFO {http.request.uri.path}
        }
      }

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
