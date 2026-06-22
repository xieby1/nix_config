{
  lib,
  runCommand,
  prettier,
}:
catwalk:
runCommand "${catwalk.id}.ts" {
  nativeBuildInputs = [ prettier ];
  content = ''
  import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

  export default function (pi: ExtensionAPI) {
    pi.registerProvider("${catwalk.id}", {
      baseUrl: "${catwalk.api_endpoint}",
      apiKey: "${catwalk.api_key}",
      api: "${ if catwalk.type == "anthropic" then "anthropic-messages"
          else if catwalk.type == "openai" then "openai-responses"
          else if catwalk.type == "openai-compat" then "openai-completions"
          else throw "Unknown api from catwalk.type ${catwalk.type}"
      }",
      models: ${builtins.toJSON (
        lib.mapAttrsToList (
          _: model: {
            inherit (model) id name;
            reasoning = model.can_reason;
            input = ["text"];
            cost = {
              input = model.cost_per_1m_in;
              output = model.cost_per_1m_out;
              cacheRead = model.cost_per_1m_in_cached;
              cacheWrite = model.cost_per_1m_out_cached;
            };
            contextWindow = model.context_window;
            maxTokens = model.default_max_tokens;
          }
        ) catwalk.models
      )}
    });
  }
'';
  passAsFile = [ "content" ];
  preferLocalBuild = true;
} ''prettier --parser typescript "$contentPath" > $out''
