{ pkgs, ... }: {
  home.packages = [
    pkgs.gh
  ];
  yq-merge.".config/gh/config.yml" = {
    generator = builtins.toJSON;
    expr = {
      git_protocol = "ssh";
    };
  };
  yq-merge.".config/gh/hosts.yml" = {
    generator = builtins.toJSON;
    expr = {
      "github.com" = {
        user = "xieby1";
        oauth_token = pkgs.lib.trim (builtins.readFile ~/Gist/Vault/AI/github-xieby1.txt);
      };
    };
  };
}
