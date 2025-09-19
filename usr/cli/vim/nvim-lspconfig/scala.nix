{ config, pkgs, ... }: let
  jre-with-proxy = let
    java-with-proxy = pkgs.writeShellScript "java" ''
      ${pkgs.jre}/bin/java \
        -Dhttp.proxyHost=127.0.0.1 \
        -Dhttp.proxyPort=${toString config.proxyPort} \
        -Dhttps.proxyHost=127.0.0.1 \
        -Dhttps.proxyPort=${toString config.proxyPort} \
        "$@"
    '';
  in pkgs.runCommand "jre_with_proxy" {} ''
    mkdir -p $out
    ${pkgs.xorg.lndir}/bin/lndir -silent ${pkgs.jre} $out
    rm $out/bin/java
    ln -s ${java-with-proxy} $out/bin/java
  '';
in {
  programs.neovim = {
    extraLuaConfig = /*lua*/ ''
      vim.lsp.enable("metals")
    '';
    extraPackages = [ (pkgs.metals.override {jre = jre-with-proxy;}) ];
  };
}
