{ stdenv
, writeShellScript
, jre
, proxyHost
, proxyPort
}: let
  java_with_proxy_sh = writeShellScript "java" ''
    ${jre}/bin/java -Dhttp.proxyHost=${proxyHost} -Dhttp.proxyPort=${proxyPort} -Dhttps.proxyHost=${proxyHost} -Dhttps.proxyPort=${proxyPort} "$@"
  '';
in builtins.derivation rec {
  name = "jre_with_proxy";
  system = builtins.currentSystem;
  builder = writeShellScript "${name}-builder" ''
    source ${stdenv}/setup

    mkdir -p $out
    for dir in ${jre}/*; do
      ln -s $dir $out/
    done

    rm $out/bin
    mkdir -p $out/bin
    for file in ${jre}/lib/openjdk/bin/*; do
      ln -s $file $out/bin/
    done

    rm $out/bin/java
    ln -s ${java_with_proxy_sh} $out/bin/java
  '';
}
