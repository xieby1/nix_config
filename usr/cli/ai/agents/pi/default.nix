{ config, pkgs, ... }: {
  imports = [
    ./extensions
    ./providers
  ];
  home.packages = [
    # TODO: using pi in pkgsu?
    (pkgs.flake-compat {src = pkgs.npinsed.ai.pi.llm-agents;})
      .defaultNix.packages.x86_64-linux.pi
  ];
  home.file.".pi/agent/projects-memory".source = config.lib.file.mkOutOfStoreSymlink ~/Gist/Data/pi/projects-memory;
  home.file.".pi/agent/pi-hermes-memory/MEMORY.md".source = config.lib.file.mkOutOfStoreSymlink ~/Gist/Data/pi/pi-hermes-memory/MEMORY.md;
  home.file.".pi/agent/pi-hermes-memory/USER.md".source = config.lib.file.mkOutOfStoreSymlink ~/Gist/Data/pi/pi-hermes-memory/USER.md;
  home.file.".pi/agent/pi-hermes-memory/skills".source = config.lib.file.mkOutOfStoreSymlink ~/Gist/Data/pi/pi-hermes-memory/skills;
}
