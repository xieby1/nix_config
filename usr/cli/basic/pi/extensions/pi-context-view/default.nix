{ pkgs, ... }:
{
  # Raw TypeScript source, zero runtime dependencies: Pi injects the
  # @earendil-works/* peer packages at runtime, so there is no npm build step.
  # Pi finds the entry point via the `pi.extensions` field in package.json.
  # `/context config` writes ~/.pi/agent/extensions/pi-context-view.json, a
  # sibling of this directory, so it stays writable.
  #
  # Pinned at v0.7.1: v0.7.2 refuses to run on Pi < 1.3.0, and pkgsu ships 1.2.0.
  home.file.".pi/agent/extensions/pi-context-view".source = pkgs.npinsed.ai.pi.pi-context-view;
}
