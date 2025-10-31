{ pkgs, ... }: {
  programs.firefox = {
    profiles.xieby1 = {
      extensions.packages = [ pkgs.nur.repos.rycee.firefox-addons.brotab ];
    };
  };

  home.packages = [ pkgs.brotab ];
  home.file.brotab_mediator = rec {
    target = ".mozilla/native-messaging-hosts/brotab_mediator.json";
    source = pkgs.runCommand "brotab_mediator" {} ''
      export HOME=.
      ${pkgs.brotab}/bin/brotab install
      cp ${target} $out
    '';
  };
}
