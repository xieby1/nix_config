{ config, pkgs, ... }: let
  jre_with_proxy = pkgs.callPackage ./jre_with_proxy.nix {
    jre = pkgs.openjdk_headless;
    proxyHost = "127.0.0.1";
    proxyPort = toString config.proxyPort;
  };
in {
  programs.neovim = {
    extraLuaConfig = /*lua*/ ''
      vim.lsp.enable("metals")
    '';
    extraPackages = [ (pkgs.metals.override {jre = jre_with_proxy;}) ];
  };
}
