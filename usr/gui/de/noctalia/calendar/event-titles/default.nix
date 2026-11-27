{ ... }: {
  nixpkgs.overlays = [
    (self: super: {
      noctalia = super.noctalia.overrideAttrs (old: {
        patches = (old.patches or []) ++ [
          ./main.patch
        ];
      });
    })
  ];
}
