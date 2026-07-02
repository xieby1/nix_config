{ pkgs, ... }: {
  # ponytail has zero npm dependencies; Pi discovers extensions via the
  # `pi.extensions`/`pi.skills` fields in the root package.json, so the
  # raw source tree is sufficient — no npm build needed.
  home.file.".pi/agent/extensions/ponytail".source = pkgs.applyPatches {
    name = "ponytail";
    src = pkgs.npinsed.ai.pi.ponytail;
    patches = [ ./ponytail-status.patch ];
  };
  yq-merge.".pi/agent/settings.json" = {
    generator = builtins.toJSON;
    expr = {
      skills = [ "~/.pi/agent/extensions/ponytail/skills" ];
    };
  };
}
