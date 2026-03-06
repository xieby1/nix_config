if [[ ! -d ~/.config/npins || ~/.config/timestamp -ot ~/.config/nixpkgs/npins/sources.json ]]; then
  NIXPKGS=$(nix eval --impure --expr '(import ~/.config/nixpkgs/npins).nixpkgs.outPath' | tr -d '"')
  HOME_MANAGER=$(nix eval --impure --expr '(import ~/.config/nixpkgs/npins).home-manager.outPath' | tr -d '"')
  mkdir -p ~/.config/npins
  nix-store --add-root ~/.config/npins/nixpkgs      --realise $NIXPKGS
  nix-store --add-root ~/.config/npins/home-manager --realise $HOME_MANAGER
  touch ~/.config/timestamp
fi
export NIX_PATH="nixpkgs=$(realpath ~/.config/npins/nixpkgs):home-manager=$(realpath ~/.config/npins/home-manager):nixos-config=/etc/nixos/configuration.nix"
