let
  pkgs = import <nixpkgs> {};
in pkgs.runCommand "AGENTS.md" {} ''
  awk '
    /^## Full Template \(Recommended\)/{found=1}
    found && /^```markdown$/{in_block=1; next}
    found && in_block && /^```$/{exit}
    in_block{print}
  ' ${pkgs.npinsed.ai.vestige}/docs/CLAUDE-SETUP.md > $out
''
