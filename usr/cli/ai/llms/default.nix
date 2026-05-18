{ pkgs, ... }: {
  services.ollama = {
    enable = true;
    package = pkgs.pkgsu.ollama-vulkan;
    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "32000"; # TODO: config
    };
  };
}
