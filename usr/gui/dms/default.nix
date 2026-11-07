{ pkgs, ... }:
let
  patchedDmsShell = pkgs.dms-shell.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      substituteInPlace $out/share/quickshell/dms/Modules/Notifications/Popup/NotificationPopup.qml \
        --replace-fail 'visible: cardHoverHandler.hovered' 'visible: true' \
        --replace-fail 'visible: actionCount < 3 && cardHoverHandler.hovered' 'visible: actionCount < 3'
    '';
  });
in
{
  imports = [
    ./avatar.nix
    ./settings.nix
    ./plugins
    ./clsettings.nix
  ];
  cachix_packages = [ patchedDmsShell ];
  home.packages = [
    patchedDmsShell
    pkgs.quickshell
    pkgs.dgop

    # App icons for many apps not showing in App Launcher.
    # https://github.com/AvengeMedia/DankMaterialShell/issues/1132
    pkgs.papirus-icon-theme
    pkgs.adwaita-icon-theme
  ];
}
