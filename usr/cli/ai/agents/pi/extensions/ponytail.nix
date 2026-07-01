{ pkgs, ... }: {
  # ponytail has zero npm dependencies; Pi discovers extensions via the
  # `pi.extensions`/`pi.skills` fields in the root package.json, so the
  # raw source tree is sufficient — no npm build needed.
  home.file.".pi/agent/extensions/ponytail".source = pkgs.npinsed.ai.pi.ponytail;
}
