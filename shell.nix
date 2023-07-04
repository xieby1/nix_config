let
  name = "nix_config";
  pkgs = import <nixpkgs> {};
  h_content = builtins.toFile "h_content" ''
    * Show this help: `h`
    * First run: `bundle install`
    * Build: `bundle exec jekyll build`
    * Local server: `bundle exec jekyll serve -H 0.0.0.0 -P 4000`
  '';
  _h_ = pkgs.writeShellScriptBin "h" ''
    ${pkgs.glow}/bin/glow ${h_content}
  '';
in pkgs.mkShell {
  inherit name;
  buildInputs = with pkgs; [
    _h_
    bundler
    jekyll
  ];
  shellHook = ''
    h
  '';
}
