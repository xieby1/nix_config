{ ... }: {
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      directory = {
        truncation_length = 0;
        truncate_to_repo = false;
      };
      custom.fhs = {
        when = "test -e /nix-support/is-fhsenv";
        format = "[󱄅FHS]($style) ";
        style = "bold yellow";
      };
    };
  };
}
