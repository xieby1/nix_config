{ pkgs, lib, config, ... }: let
  # llm-agents.hermes-agent vs hermes-agent/flake.nix
  # - llm-agents.hermes-agent non-cached closure size: 278,345,760B
  # - hermes-agent/flake.nix non-cached closure size: 1,336,474,112B
  # Thus llm-agents.hermes-agent is preferred
  hermes-agent = (pkgs.flake-compat {src=pkgs.npinsed.ai.llm-agents;})
    .defaultNix.packages.${pkgs.stdenv.system}.hermes-agent
    .overrideAttrs (old: {
      # TODO: Remove patches once llm-agents updates past 2026.5.14.
      # Upstream PR #25075 fixes zsh completion (_hermes "$@" -> compdef).
      # The eval approach below will work once that lands.
      patches = old.patches or [] ++ [
        # zsh completion fix#22234
        (builtins.fetchurl {
          url = "https://github.com/NousResearch/hermes-agent/pull/22234.patch";
          sha256 = "0qc1nakb74xliw8m7kcj9bb2fxn4rpvr85hbvm39anqla0kqxyib";
        })
      ];
    });
in {
  home.packages = [
    hermes-agent
  ];
  yq-merge.".hermes/config.yaml" = {
    generator = builtins.toJSON;
    expr = {
      model = {
        default = "kimi-for-coding";
        provider = "kimi-coding";
        base_url = config.ai.kimi.api_endpoint;
      };
      web = {
        backend = "tavily";
      };
    };
  };
  yq-merge.".hermes/.env" = {
    generator = lib.generators.toKeyValue {};
    yqExtraArgs = "-p=props -o=props --properties-separator='='";
    yqLoadFunc = "load_props";
    expr = {
      KIMI_API_KEY = config.ai.kimi.api_key;
      MINIMAX_CN_API_KEY = config.ai.minimax-china.api_key;
      TAVILY_API_KEY = config.ai.tavily.api_key;
    };
  };

  # zsh completion via fpath (not eval, which breaks _arguments)
  # https://github.com/NousResearch/hermes-agent/issues/6122
  home.file."zsh-completions/_hermes" = {
    target = ".zsh/completions/_hermes";
    source = pkgs.runCommand "hermes-zsh-completion" {} ''
      ${hermes-agent}/bin/hermes completion zsh > $out
    '';
  };
  programs.zsh.initContent = lib.mkBefore ''
    fpath+=("$HOME/.zsh/completions")
  '';

  home.file.".hermes/memories/USER.md".source = config.lib.file.mkOutOfStoreSymlink ~/Gist/Data/hermes/memories/USER.md;
  home.file.".hermes/memories/MEMORY.md".source = config.lib.file.mkOutOfStoreSymlink ~/Gist/Data/hermes/memories/MEMORY.md;
  home.file.".hermes/skills".source = config.lib.file.mkOutOfStoreSymlink ~/Gist/Data/hermes/skills;
}
