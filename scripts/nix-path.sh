if [[ ! -d ~/.config/npins || ~/.config/npins-timestamp -ot ~/.config/nixpkgs/npins/sources.json ]]; then
  mkdir -p ~/.config/npins
  nix-store --add-root ~/.config/npins/nixpkgs      \
    --realise $(nix --extra-experimental-features nix-command eval --impure --expr '(import ~/.config/nixpkgs/npins).nixpkgs.outPath' | tr -d '"')
  nix-store --add-root ~/.config/npins/home-manager \
    --realise $(nix --extra-experimental-features nix-command eval --impure --expr '(import ~/.config/nixpkgs/npins).home-manager.outPath' | tr -d '"')
  if [[ $USER == "nix-on-droid" ]]; then
    nix-store --add-root ~/.config/npins/nix-on-droid \
      --realise $(nix --extra-experimental-features nix-command eval --impure --expr '(import ~/.config/nixpkgs/npins).nix-on-droid.outPath' | tr -d '"')
  fi
  touch ~/.config/npins-timestamp
fi

NIX_PATH="nixpkgs=$(realpath ~/.config/npins/nixpkgs):home-manager=$(realpath ~/.config/npins/home-manager)"
if [[ $USER == "nix-on-droid" ]]; then
  NIX_PATH=$NIX_PATH:nix-on-droid=$(realpath ~/.config/npins/nix-on-droid)
else
  NIX_PATH=$NIX_PATH:nixos-config=/etc/nixos/configuration.nix
fi
export NIX_PATH
