{ pkgs, ... }: {
  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
    hosts = {
      "github.com" = {
        user = "xieby1";
        oauth_token = pkgs.lib.trim (builtins.readFile ~/Gist/Vault/AI/github-gh.txt);
        git_protocol = "ssh";
      };
    };
  };
}
