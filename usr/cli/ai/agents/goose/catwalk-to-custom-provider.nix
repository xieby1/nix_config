{ pkgs, lib, goose-unwrapped }: catwalk: let
  api_key_env = lib.toUpper (builtins.replaceStrings ["-"] ["_"] catwalk.id);
in {
  yq-merge.".config/goose/config.yaml" = {
    generator = builtins.toJSON;
    yqExtraArgs = "-P";
    expr = {
      providers = {
        ${catwalk.id} = {
          enabled = true;
          # TODO: redundant?
          model = catwalk.default_large_model_id;
          configured = true;
        };
      };
    };
  };
  yq-merge.".config/goose/custom_providers/${catwalk.id}.json" = {
    generator = builtins.toJSON;
    yqExtraArgs = "-P";
    expr = {
      name = catwalk.id;
      engine = if catwalk.type == "anthropic" then "anthropic"
          else if catwalk.type == "openai" then "openai"
          else if catwalk.type == "openai-compat" then "openai"
          else throw "Unknown engine from catwalk.type ${catwalk.type}";
      display_name = catwalk.name;
      inherit api_key_env;
      base_url = catwalk.api_endpoint;
      dynamic_models = true;
      # Currently the models.xxx.context_limit does not works, see: https://github.com/aaif-goose/goose/issues/8780
      # Only GOOSE_PREDEFINED_MODELS works.
      # So we configure the per-model context_limit through GOOSE_PREDEFINED_MODELS env, see below.
      models = [];
      supports_streaming = true;
      requires_auth = true;
    };
  };
  yq-merge.".config/goose/secrets.yaml" = {
    generator = builtins.toJSON;
    yqExtraArgs = "-P";
    expr = {
      ${api_key_env} = catwalk.api_key;
    };
  };

  home.packages = let
    goose-wrapped = pkgs.runCommand "goose-${catwalk.id}" {
      nativeBuildInputs = [pkgs.makeWrapper];
      passthru.unwrapped = goose-unwrapped;
    } ''
      mkdir -p $out/bin
      makeWrapper ${goose-unwrapped}/bin/goose $out/bin/goose-${catwalk.id} \
        --set GOOSE_DISABLE_KEYRING 1 \
        --set GOOSE_PROVIDER "${catwalk.id}" \
        --set GOOSE_PREDEFINED_MODELS '${builtins.toJSON (
          lib.mapAttrsToList (
            name: model: {inherit name; context_limit = model.context_window;}
          ) catwalk.models
        )}'
    '';
  in [ goose-wrapped ];
}
