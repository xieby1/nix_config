{ pkgs, ... }: {
  # No npm build needed: the only runtime dep is its sibling workspace package
  # (@juicesharp/rpiv-config), so drop it into node_modules by hand. Pi aliases
  # typebox / pi-tui / pi-coding-agent itself, and rpiv-i18n is an optional peer.
  home.file.".pi/agent/extensions/rpiv-ask-user-question" = {
    source = pkgs.runCommand "rpiv-ask-user-question" { } ''
      mkdir -p $out/node_modules/@juicesharp
      cp -r ${pkgs.npinsed.ai.pi.rpiv-mono}/packages/rpiv-ask-user-question/. $out/
      cp -r ${pkgs.npinsed.ai.pi.rpiv-mono}/packages/rpiv-config \
        $out/node_modules/@juicesharp/rpiv-config
      # Nothing at runtime reads docs/ or the tests; their deps (vitest,
      # rpiv-test-utils) are not installed either.
      # cp keeps the store's read-only modes.
      chmod -R u+w $out
      rm -rf $out/docs
      find $out -name '*.test.ts' -delete
      rm -f $out/test-fixtures.ts
    '';
  };
}
