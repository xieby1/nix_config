{ pkgs, ... }: let
  inherit (pkgs.nur.repos.rycee.firefox-addons) smartproxy;
  opt = import ../../../../opt.nix;
in {
  programs.firefox = {
    profiles.xieby1 = {
      extensions = [ smartproxy ];
    };
  };
  firefox-extensions.xieby1 = {
    browser-extension-data."${smartproxy.addonId}" = {
      storage = {
        activeProfileId = "InternalProfile_SmartRules";
        defaultProxyServerId = "defaultProxyServerId";
        proxyServers = [{
          name = "nix";
          id = "defaultProxyServerId";
          order = 0;
          host = "127.0.0.1";
          port = opt.proxyPort;
          protocol = "HTTP";
          username = "";
          password = "";
          proxyDNS = true;
          failoverTimeout = null;
        }];
        proxyProfiles = [{
          profileName = "Smart Proxy";
          profileId = "InternalProfile_SmartRules";
          profileProxyServerId = "defaultProxyServerId";
          profileType = 2;
          enabled = true;
          rulesSubscriptions = [{
            enabled = true;
            refreshRate = 6000;
            id = "gfwlist";
            name = "gfwlist";
            url = "https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt";
            obfuscation = "Base64";
            format = 0;
            applyProxy = 1;
            username = "";
            password = "";
          }];
          profileTypeConfig =  {
            builtin = true;
            editable = true;
            selectable = true;
            supportsSubscriptions = true;
            supportsProfileProxy = true;
            customProxyPerRule = true;
            canBeDisabled = true;
            supportsRuleActionWhitelist = true;
            defaultRuleActionIsWhitelist = false;
          };
        }];
      };
    };
  };
}
