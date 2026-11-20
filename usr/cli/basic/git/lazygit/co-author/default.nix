{ ... }: {
  nixpkgs.overlays = [
    (self: super: {
      lazygit = super.lazygit.overrideAttrs (old: {
        patches = (old.patches or []) ++ [ ./main.patch ];
        nativeCheckInputs = (old.nativeCheckInputs or []) ++ [ self.git ];
        postCheck = (old.postCheck or "") + "\n" + ''
          go test ./pkg/commands/git_commands ./pkg/commands/models ./pkg/config ./pkg/gui/presentation ./pkg/gui/presentation/authors
        '';
      });
    })
  ];
  programs.lazygit.settings.gui.commitCoAuthorLongLength = 4;
}
