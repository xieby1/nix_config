{
  catwalk-provider,
  api,
  model-extra ? {},

  lib,
  runCommand,
  prettier,
}:
assert lib.assertOneOf "api" api ["anthropic-messages" "openai-completions" "openai-responses"];
runCommand "${catwalk-provider.id}.ts" {
  nativeBuildInputs = [ prettier ];
  content = ''
  import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

  export default function (pi: ExtensionAPI) {
    pi.registerProvider("${catwalk-provider.id}", {
      baseUrl: "${catwalk-provider.api_endpoint}",
      apiKey: "${catwalk-provider.api_key}",
      api: "${api}",
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
          } // model-extra
        ) catwalk-provider.models
      )}
    });
  }
'';
  passAsFile = [ "content" ];
  preferLocalBuild = true;
} ''prettier --parser typescript "$contentPath" > $out''
