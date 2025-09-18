#MC # JRE with Proxy
#MC
#MC Let JRE aware of proxy by default.
#MC This package can be used standalone, while my main usage is for nvim-metals lsp.
#MC Without proxy, the scala package update make me headached.
#MC
#MC For usage example, see [my nvim-metals config](./default.nix)
{ runCommand
, writeShellScript
, jre
, lndir
, proxyHost
, proxyPort
}: let
  java_with_proxy_sh = writeShellScript "java" ''
    ${jre}/bin/java -Dhttp.proxyHost=${proxyHost} -Dhttp.proxyPort=${proxyPort} -Dhttps.proxyHost=${proxyHost} -Dhttps.proxyPort=${proxyPort} "$@"
  '';
in runCommand "jre_with_proxy" {} ''
  mkdir -p $out
  ${lndir}/bin/lndir -silent ${jre} $out
  rm $out/bin/java
  ln -s ${java_with_proxy_sh} $out/bin/java
''
