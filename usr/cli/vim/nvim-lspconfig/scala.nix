# If metals throw errors, check <workspace>/.metals/metals.log
# Try following steps:
# * rm -rf .metals/ ~/.bloop/* ~/.cache/mill/ ~/.cache/coursier/
# * check all dependent libs have been downloaded to workspace, e.g. update git submodule
{ config, pkgs, ... }: let
  jre-with-proxy = pkgs.runCommand "jre-with-proxy" {
    nativeBuildInputs = [pkgs.makeWrapper];
  } ''
    mkdir -p $out
    ${pkgs.xorg.lndir}/bin/lndir -silent ${pkgs.jre} $out
    wrapProgram $out/bin/java --add-flag -Dhttp.proxyHost=127.0.0.1 \
                              --add-flag -Dhttp.proxyPort=${toString config.proxyPort} \
                              --add-flag -Dhttps.proxyHost=127.0.0.1 \
                              --add-flag -Dhttps.proxyPort=${toString config.proxyPort}
    # Metals will check the `release` in java home.
    # If not exist, it will throw "release file missing JAVA_VERSION property - using Bloop's JVM version"
    # The `release file is located in lib/openjdk/release`
    ln -s $out/lib/openjdk/release $out/
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
          # [Note1]: use mill in system, preventing the situation where I can compile but I cannot use metals
          "-Dmetals.millScript=mill"

          # If mill command (specified by millScript) is not found,
          # then metals will use java to run mill.contrib.bloop.Bloop/install
          "-Dmetals.javaHome=${jre-with-proxy}"

          # Cannot go-to-definition in build.sc.
          # The problem can be solved by using mill-bsp as bsp, instead of using bloop,
          # for more details see: https://github.com/com-lihaoyi/mill/discussions/2688
          # According metals doc:
          #   "Using Mill with Bloop is the current preferred way by Metals."
          # I have tried defaultBspToBuildTool=true, which does not work!
          #
          # I learned from nvim-metals the following code to send `bsp-switch` command to metals.
          # vim.lsp.get_client_by_id(1):request("workspace/executeCommand", {command="metals.bsp-switch"})
          #
          # NOTED: If using mill-bsp, make sure run `mill -i mill.bsp.BSP/install` before using.
          "-Dmetals.defaultBspToBuildTool=true"
        ];
      }))
      (pkgs.coursier.override { jre = jre-with-proxy; })
    ];
    # extraWrapperArgs = [
    #   "--set-default" "JAVA_HOME" "${jre-with-proxy}"
    # ];
  };
  # [Paired with above Note1]:
  # If system does not have mill, then metals will use a 0.5.0 mill script to run:
  # Optional absolute path to a mill executable to use for running
  # `mill mill.contrib.bloop.Bloop/install`.
  # This mill needs JAVA_HOME.
  programs.bash.bashrcExtra = /*bash*/''
    # make .metals/mill happy.
    export JAVA_HOME=${jre-with-proxy};
  '';

  # nvim-metals proxy for bloop
  home.file.jvmopts = {
    text = ''
      -Dhttps.proxyHost=127.0.0.1
      -Dhttps.proxyPort=${toString config.proxyPort}
      -Dhttp.proxyHost=127.0.0.1
      -Dhttp.proxyPort=${toString config.proxyPort}
    '';
    target = ".bloop/.jvmopts";
  };
}
