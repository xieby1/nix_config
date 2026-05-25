{ pkgs, lib, config, ... }: let
  hermes-agent = import ./package.nix;
in {
  imports = [
    ./container-service
  ];

  home.packages = [
    hermes-agent
  ];
  home.shellAliases.hermes-tui = "hermes --tui";

  yq-merge.".hermes/config.yaml" = {
    generator = builtins.toJSON;
    yqExtraArgs = "-P";
    expr = {
      model = {
        default = "kimi-for-coding";
        provider = "kimi-coding";
        base_url = config.ai.kimi.api_endpoint;
      };
      # the avaliable fields see: <hermes-agent>/hermes_cli/config.py: _normalize_custom_provider_entry
      providers = {
        jw-claude = {
          name = "JW Claude";
          api = config.ai.jw-claude.api_endpoint;
          api_key = config.ai.jw-claude.api_key;
          transport = "anthropic_messages";
        };
        jw-codex = {
          name = "JW Codex";
          api = config.ai.jw-codex.api_endpoint;
          api_key = config.ai.jw-codex.api_key;
          transport = "codex_responses";
          models."gpt-5.5" = {
            context_length = 1000 * 1000;
          };
        };
      };
      web = {
        backend = "tavily";
        search_backend = "tavily";
        extract_backend = "tavily";
      };
      display = {
        show_reasoning = true;
        tool_progress = "all";
        tool_preview_length = 0; # unlimited
        streaming = true;
      };
      mcp_servers = {
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
        github = {
          command = ''${pkgs.github-mcp-server}/bin/github-mcp-server'';
          args = ["stdio"];
          env = { GITHUB_PERSONAL_ACCESS_TOKEN = lib.trim (builtins.readFile "${config.home.homeDirectory}/Gist/Vault/AI/github-mcp-server-minimal.txt");};
        };
        xiaohongshu = {
          url = "http://localhost:18060/mcp";
          enabled = false;
          timeout = 300;
          connect_timeout = 30;
        };
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
