{ config, pkgs, ... }: let
  inherit (pkgs.nur.repos.rycee.firefox-addons) zeroomega;

  # A fixed proxy profile pointing at 127.0.0.1:<port>.
  # ZeroOmega reads these from browser.storage.local as `+<name>` keys.
  fixedProfile = name: port: {
    inherit name;
    profileType = "FixedProfile";
    fallbackProxy = {
      scheme = "http";
      host = "127.0.0.1";
      inherit port;
    };
  };
in {
  programs.firefox = {
    profiles.xieby1 = {
      extensions.packages = [ zeroomega ];
    };
  };
  firefox-extensions.xieby1 = {
    browser-extension-data."${zeroomega.addonId}" = {
      storage = {
        schemaVersion = 2;

        # --- active profile + rule-list refresh ---
        "-startupProfileName" = "auto switch";
        "-quickSwitchProfiles" = [];
        # > 0 enables refreshing rule-list profiles on startup (minutes).
        "-downloadInterval" = 1440;

        # --- proxy servers ---
        "+nix" = fixedProfile "nix" config.proxyPort;
        "+tailscale" = fixedProfile "tailscale"
          config.my.tailscale.instances.official.httpPort;

        # --- gfwlist rule list: listed domains -> nix, everything else -> direct ---
        "+gfwlist" = {
          name = "gfwlist";
          profileType = "RuleListProfile";
          format = "AutoProxy";
          sourceUrl = "https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt";
          matchProfileName = "nix";     # normal rules = proxy
          defaultProfileName = "direct"; # @@ rules + fallback = direct
        };

        # --- active profile: tailscale CGNAT 100.64.0.0/10 -> tailscale, else gfwlist ---
        "+auto switch" = {
          name = "auto switch";
          profileType = "SwitchProfile";
          defaultProfileName = "gfwlist";
          rules = [{
            condition = {
              conditionType = "IpCondition";
              ip = "100.64.0.0";
              prefixLength = 10;
            };
            profileName = "tailscale";
          }];
        };
      };
    };
  };
}
