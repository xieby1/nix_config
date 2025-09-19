# If metals throw errors, check <workspace>/.metals/metals.log
# Try following steps:
# * clean .metals/, ~/.bloop/, ~/.cache/mill
# * check all dependent libs have been downloaded to workspace, e.g. update git submodule
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
    extraPackages = [
      ((pkgs.metals.override {
        jre=jre-with-proxy;
      }).overrideAttrs (old: {
        extraJavaOpts = toString [
          old.extraJavaOpts
          /*
            User configuration options can optionally be provided via server properties using the -Dmetals. prefix.
            For more user configuration, see: https://scalameta.org/metals/docs/integrations/new-editor/#metals-user-configuration
          */
          # use mill in system, preventing the situation where I can compile but I cannot use metals
          # If mill is provided:
          "-Dmetals.millScript=mill"

          # If mill command (specified by millScript) is not found,
          # then metals will use java to download mill
          "-Dmetals.javaHome=${jre-with-proxy}"
        ];
      }))
    ];
  };
}
