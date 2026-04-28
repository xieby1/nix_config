{ pkgs, config, ... }: let
  forgecode = (pkgs.flake-compat {src = pkgs.npinsed.ai.forgecode;}).defaultNix.default
    # The version and APP_VERSION is 0.1.0-dev, which is out-of-date
    .overrideAttrs (_old: rec {
      # Forge skips update checks when version contains "dev", avoiding prompts like:
      # `Confirm upgrade from v2.9.9 -> v2.10.0 (latest)? Y/n:`
      # See: crates/forge_main/src/update.rs
      version = "${pkgs.npinsed.ai.forgecode.version}-dev";
      APP_VERSION=version;
      __intentionallyOverridingVersion=true;
      patches = [./agents-skills-upward-discovery.patch];
    });
in {
  home.packages = [ forgecode ];
  cachix_packages = [ forgecode ];
  yq-merge.".forge/.credentials.json" = {
    generator = builtins.toJSON;
    expr = [{
      id = "minimax";
      auth_details.api_key = config.ai.minimax-china.api_key;
      url_params.HOSTNAME = "api.minimaxi.com";
    }{
      id = "kimi_coding";
      auth_details.api_key = config.ai.kimi.api_key;
    }{
      id = "deepseek";
      auth_details.api_key = config.ai.deepseek.api_key;
    }];
  };
  yq-merge.".forge/.mcp.json" = {
    generator = builtins.toJSON;
    expr = {
      mcpServers = {
        ddgs = {
          command = ''${
            pkgs.pkgsu.python3Packages.ddgs.overridePythonAttrs (old: {
              dependencies = old.dependencies
                ++ old.optional-dependencies.mcp
                ++ old.optional-dependencies.api;
            })
          }/bin/ddgs'';
          args = ["mcp"];
        };
        minimax-coding-plan-mcp = {
          command = "${pkgs.uv}/bin/uvx";
          args = [
            "-p" "${pkgs.python3}/bin/python3"
            "minimax-coding-plan-mcp" "-y"
          ];
          env = {
            MINIMAX_API_KEY = config.ai.minimax-china.api_key;
            MINIMAX_API_HOST = "https://api.minimaxi.com";
          };
        };
      };
    };
  };
}
