{ pkgs , ... }: let
  hermes-image = pkgs.dockerTools.buildImageWithNixDb {
    name = "hermes";
    tag = "latest";
    copyToRoot = pkgs.buildEnv {
      name = "root";
      paths = [
        pkgs.bashInteractive
        pkgs.cacert
        pkgs.coreutils
        pkgs.file
        pkgs.git
        pkgs.gnutar
        pkgs.nix
        pkgs.openssh
        pkgs.wget

        (pkgs.flake-compat {src=pkgs.npinsed.ai.llm-agents;})
          .defaultNix.packages.${pkgs.stdenv.system}.hermes-agent
      ];
    };
  };
in {
  services.podman = {
    images.hermes = {
      # https://github.com/nix-community/home-manager/pull/6137
      image = "docker-archive:${hermes-image}";
      tag = "localhost/hermes:latest";
    };
    # containers.hermes = {
    #   entrypoint = "TODO";
    #   environment = {};
    #   image = null; # TODO
    #   network = "host";
    #   volumes = [
    #     "/home/xieby1/.local/state/hermes-container:/root"
    #   ];
    # };
  };
}
