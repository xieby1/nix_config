# Co-author display

`main.patch` adds `gui.commitCoAuthorLongLength` to LazyGit.
The default is `0` (disabled); this module enables it with the width configured in `default.nix`, measured in terminal cells.

- Normal commits view: append `&` directly to the author when co-authors exist, or one blank cell otherwise.
- Expanded commits view: show names without emails in a fixed-width column after the author.
  Multiple names are comma-separated and overflow uses LazyGit's existing truncation.
- Disabled: preserve the original rendering and Git log format.

Git extracts case-insensitive `Co-authored-by` trailers in the existing log/show calls.
The separate Reflog list is unchanged.

The module extends `pkgs.lazygit` through an overlay, preserving earlier patches and check hooks.
Home Manager uses that package by default; additional patch modules can append their own overlays without redefining `programs.lazygit.package`.

## Verify or update

Build the package and run the included loader/rendering tests without activating Home Manager:

```sh
nix-build --no-out-link -E '(import <nixpkgs> { overlays = (import ./usr/cli/basic/git/lazygit/co-author {}).nixpkgs.overlays; }).lazygit'
```

When updating LazyGit, rebase the patch against `pkgs.lazygit.src` if needed, then repeat this build.
Check normal and expanded TUI views, including a viewport containing only commits without co-authors.
