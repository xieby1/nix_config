if not ('~/.config/npins' | path exists) or not ('~/.config/npins-timestamp' | path exists) or (
  (%ls ~/.config/npins-timestamp | get 0.modified) < (%ls ~/.config/nixpkgs/npins/sources.json | get 0.modified)
) {
  mkdir ~/.config/npins
  ^nix-store --add-root ~/.config/npins/nixpkgs --realise (
    ^nix --extra-experimental-features nix-command eval --impure --raw --expr '(import ~/.config/nixpkgs/npins).nixpkgs.outPath'
  )
  ^nix-build ~/.config/nixpkgs/scripts/bootstrap/home-manager.nix -o ~/.config/npins/home-manager
  if $env.USER == 'nix-on-droid' {
    ^nix-store --add-root ~/.config/npins/nix-on-droid --realise (
      ^nix --extra-experimental-features nix-command eval --impure --raw --expr '(import ~/.config/nixpkgs/npins).nix-on-droid.outPath'
    )
  }
  touch ~/.config/npins-timestamp
}

$env.NIX_PATH = ([
  $"nixpkgs=('~/.config/npins/nixpkgs' | path expand --strict)"
  $"home-manager=('~/.config/npins/home-manager' | path expand --strict)"
  (if $env.USER == 'nix-on-droid' {
    $"nix-on-droid=('~/.config/npins/nix-on-droid' | path expand --strict)"
  } else {
    'nixos-config=/etc/nixos/configuration.nix'
  })
  $"npins=('~/.config/nixpkgs/npins' | path expand --strict)"
] | str join ':')
