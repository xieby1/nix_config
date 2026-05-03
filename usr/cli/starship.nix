{ ... }: {
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      directory = {
        truncation_length = 0;
        truncate_to_repo = false;
      };
    };
  };
}
