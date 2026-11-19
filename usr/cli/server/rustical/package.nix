{ pkgs }:
pkgs.rustical.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./base-path.patch ];
})
