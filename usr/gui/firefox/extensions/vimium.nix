{ config, pkgs, lib, ... }: let
  inherit (pkgs.nur.repos.rycee.firefox-addons) vimium;
in {
  programs.firefox = {
    profiles.xieby1 = {
      extensions.packages = [
        vimium
      ];
    };
  };

  home.file.vimium_sql = let
    # retrieve json:
    # sqlite3 storage-sync-v2.sqlite "SELECT data FROM storage_sync_data WHERE ext_id='{d7742d87-e61d-4b78-b8a1-b469842139fa}';"
    json = /*json*/ ''{
      "exclusionRules": [{
        "passKeys": "",
        "pattern": "*:77[0-9][0-9]*"
      }],
      "settingsVersion": "${lib.removePrefix "vimium-" vimium.name}"
    }'';
    relDir = "${config.programs.firefox.profilesPath}/xieby1";
    absDir = "${config.home.homeDirectory}/${relDir}";
    relTarget = "${relDir}/browser-extension-data/${vimium.addonId}/sql";
    absTarget = "${config.home.homeDirectory}/${relTarget}";
  in {
    text = /*sql*/ "UPDATE storage_sync_data SET data = '${json}' WHERE ext_id = '${vimium.addonId}';";
    target = relTarget;
    onChange = /*bash*/ ''
      if [[ -e ${absDir}/storage-sync-v2.sqlite ]]; then
        echo ⛁ updating vimium settings in ${absDir}/storage-sync-v2.sqlite
        ${pkgs.sqlite}/bin/sqlite3 ${absDir}/storage-sync-v2.sqlite < ${absTarget}
      else
        echo ⛃ next time update vimium settings in ${absDir}/storage-sync-v2.sqlite
        rm ${absTarget}
      fi
    '';
  };
}
