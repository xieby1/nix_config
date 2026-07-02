{ pkgs, lib, config, ... }: {
  yq-merge.".config/goose/config.yaml" = {
    generator = builtins.toJSON;
    yqExtraArgs = "-P";
    expr = {
      # TODO: reduce MCP config duplication in all agents
      extensions = {
        ddgs = {
          enabled = true;
          type = "stdio";
          name = "ddgs";
          cmd = config.ai.mcp.ddgs.command;
          args = config.ai.mcp.ddgs.args;
        };
      };
    };
  };
}
