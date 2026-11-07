{ pkgs, config, ... }: let
  gh-user = user: {
    home.packages = [(
      pkgs.runCommand "gh-${user}" {
        nativeBuildInputs = [pkgs.makeWrapper];
      } ''
        mkdir -p $out/bin
        makeWrapper ${pkgs.gh}/bin/gh $out/bin/gh-${user} --set GH_CONFIG_DIR ${config.home.homeDirectory}/.config/gh/${user}
      ''
    )];
    yq-merge.".config/gh/${user}/config.yml" = {
      generator = builtins.toJSON;
      expr = {
        git_protocol = "ssh";
      };
    };
    yq-merge.".config/gh/${user}/hosts.yml" = {
      generator = builtins.toJSON;
      expr = {
        "github.com" = {
          user = "${user}";
          oauth_token = pkgs.lib.trim (builtins.readFile ~/Gist/Vault/AI/github-${user}.txt);
        };
      };
    };
  };
in {
  imports = [
    (gh-user "xieby1")
    (gh-user "nanhu")
  ];
  home.packages = [
    pkgs.gh
  ];
}
